# Analytics contract và dashboard dự thảo

Status proposed. Ngưỡng dưới đây từ roadmap người dùng, **không phải kết quả beta**.
Hiện chưa có pipeline/KPI data. Không gửi health detail, diagnosis, free text, email,
token, precise location, sport/duration hay health-rest reason trong events chung.

## Envelope, consent và vận chuyển

Envelope v1: `event_id` UUID, `schema_version=1`, `event_name`, `occurred_at` UTC,
`recorded_at` UTC, server `received_at`, `subject_id` random pseudonym per installation
+ owner, `installation_id` random, `app_version`, `platform`, `policy_version`,
`cohort_id`, `experiment_id/variant` nullable, `commitment_id/session_id/recovery_id`
nullable theo event, `entity_revision`, `consent_generation`, allowlisted properties.
Không gửi raw owner/auth user UUID trong payload. Entity IDs opaque, không chứa email.
Experiment assignment persist một lần theo subject, không re-randomize mỗi app mở.

D03: week boundaries dùng UTC snapshot của commitment, không suy lại từ device zone
hay received_at. `commitment_created`/`commitment_week_finalized` dự kiến thêm opaque
`series_id`, `period_sequence`, `period_kind`; transition_week phải khớp period_kind.
Không cần gửi raw device timezone để đo adherence/retention. Thay đổi schema event,
consent và cách loại transition khỏi KPI vẫn thuộc D11/D13 chờ duyệt. Ví dụ kỳ chuyển
tiếp 6 giờ trong [D03](d03-schedule-timezone.md) không được âm thầm đưa vào full-week mean.

Consent mặc định off, lựa chọn rõ ràng và không cản core. Trước consent không queue
analytics và không backfill lịch sử; local domain audit vẫn phục vụ integrity.
Consent on tạo subject nếu cần, ghi `analytics_consent_granted` và context hiện tại;
late consent là cohort riêng, không trộn funnel first-use. Revoke purge unsent queue,
stop uploader, lưu deletion request cho server và tombstone generation để in-flight
events bị drop khi tới server sau withdrawal. Không gửi health reason cho withdrawal.
Server deletion endpoint chỉ có quyền subject đó; guest dùng token hạn chế scope,
không service role trong client. Account dùng auth xác thực binding subject phía server.
Endpoint/sink thực thi sau gate và staging test, PR0 không triển khai backend.

Raw retention đề xuất 90 ngày, aggregate không nhận diện 12 tháng; quyền export/delete
được cung cấp trước beta. Reset/reinstall/guest→account tạo subject khác, không fingerprint
hay tự nối người dùng. Báo đơn vị “consented device-owner”, số enrollment nghiên cứu
do con người quản lý riêng; không gọi distinct subject là số người thật không điều kiện.

Domain event outbox cùng transaction; uploader chỉ chạy sau commit. Retry exponential
1 phút → tối đa 6 giờ + jitter; lease timeout phục hồi crash; ack mới xóa row. Server
unique event_id; semantic dedup local theo bảng dưới. Schema lỗi/quota không được drop
im lặng: quarantine + báo số thất thoát, không chứa payload nhạy cảm trong crash logs.
Queue tối đa 10.000 events/30 ngày đề xuất; hết giới hạn ưu tiên core vẫn ghi, đánh dấu
telemetry gap và không chứng nhận KPI trong khoảng thiếu. Consent purge ưu tiên cao hơn retry.

## Event dictionary

Tất cả event v1 dưới đây cùng envelope. Domain timestamps lấy từ command, không từ
delivery time. View event chỉ khi route foreground/visible, persist key chống rebuild.

| Event | Trigger và fields riêng | Semantic dedup |
|---|---|---|
| onboarding_completed | Hoàn tất thiết lập MVP được persist; onboarding_version | subject + onboarding_version |
| commitment_created | Commit tạo tuần; target_at_start, starts/ends_at, partial_week, transition_week, creation_kind initial/repeat | commitment ID |
| session_scheduled | Commit lịch lần đầu hoặc reschedule; schedule_revision, schedule_kind, deadline_at | session + schedule_revision |
| session_completed | Valid active credit lần đầu, gồm standalone; credit_root_id, activity_id, completed_at, credited_commitment_id | credit root (không số lần tap) |
| session_missed | MissedEpisode commit; episode_id, deadline_at, detected_at, eligible_for_prompt boolean | episode ID |
| recovery_prompt_viewed | Prompt thực sự nhìn thấy foreground; episode_id, exposure_id | subject + episode (primary first exposure) |
| recovery_action_selected | Action đã persist; episode_id, action_kind reschedule/short/rest | recovery action ID |
| weekly_review_viewed | Review visible; commitment_id, review_revision | subject + commitment + review_revision |
| app_session_started | Foreground cold start hoặc sau ≥30 phút background; app_session_id | app_session_id |

Events bổ sung cần thiết cho mẫu số và correction:

| Event | Semantics |
|---|---|
| analytics_consent_granted | Xác nhận consent generation, late_consent boolean; không suy onboarding trước consent |
| onboarding_started | Flow MVP thực sự bắt đầu, attempt_id; KPI dùng lần đầu, không rebuild |
| recovery_action_completed | Action reschedule/short được linked valid activity fulfill; action ID + completion revision; không phát khi chỉ select |
| recovery_rest_acknowledged | Rest persist, generic rest không health detail; báo riêng khỏi vận động |
| session_completion_corrected | credit root + entity revision, active boolean, corrected completed_at/commitment, affects_finalized_metrics; projection upsert |
| session_missed_corrected | episode ID + revision, retracted boolean; loại miss do backdate đúng hạn |
| notification_preference_changed | enabled, reason user_selected annoyance/other/unspecified, preference revision; permission_denied là event riêng |
| notification_permission_result | granted/denied/unknown theo yêu cầu user, không suy là annoyance |
| notification_exposure_observed | Chỉ có khi xác nhận hiển thị/tap qua adapter; không gọi “scheduled” là delivered |
| commitment_week_finalized | local snapshot target, valid_credit_count, adherence, policy_version, partial/transition; week end +7 ngày; idempotent commitment + final revision |
| experiment_invited/accepted/feedback | assignment ID, experiment kind share/rules; feedback enum suitable/not_suitable; không text tự do |

`commitment_week_finalized` không âm thầm backfill events thiếu consent: chỉ phát cho
kỳ có consent coverage đủ; kỳ thiếu đánh dấu `measurement_complete=false` và loại
primary KPI, báo số loại. App không mở sau tuần thì snapshot tới muộn; dashboard
không coi thiếu event là 0 adherence mà ghi incomplete và coverage. Cần ghi nhận bias
local-only/offline đối với người rời app; retention vẫn giữ người không quay lại trong
mẫu số nếu có consent đầy đủ và ingestion window đã đóng.

## KPI / cohort definitions

`t0` = first onboarding_completed sau consent, cohort theo tuần UTC của t0 + app version.
Mọi window half-open, elapsed UTC. Ingestion allowance 7 ngày; dashboard `as_of` UTC
hiển thị rõ. Mature = as_of ≥ window end +7 ngày. Revoked/deleted subjects loại theo
data request, công bố số withdrawal; không coi withdrawn là retained/churn. Missing
events/late consent báo riêng. Không đổi denominator sau khi nhìn kết quả.

| KPI và mục tiêu | Mẫu số / tử số / censoring |
|---|---|
| Onboarding ≥80% | Subjects consented có onboarding_started đầu tiên; hoàn tất trong 24h / started; đợi 24h+7 ngày, partial riêng |
| Commitment trong 24h ≥70% | Onboarded mature 24h; ≥1 commitment tạo trong [t0,t0+24h) / onboarded |
| First activity 7 ngày ≥50% | Onboarded mature 7 ngày; ≥1 active valid credit có actual end trong [t0,t0+7d) / onboarded; event received muộn vẫn dùng actual end |
| Weekly adherence ≥60% | Mean của mỗi subject-week full/không transition với target snapshot, đủ measurement; mỗi kỳ min(1, credits/target). Tuần chưa tạo không có target: báo riêng repeat-gap và secondary adherence treating gap=0, không tự bịa target |
| Week-4 retention ≥25% | Onboarded mature 28d; ≥1 active valid credit actual end trong [t0+21d,t0+28d) / tất cả onboarded mature, kể cả không tạo commitment sau; không app-open thay activity |
| Recovery engagement ≥40% | Subject/week có ≥1 eligible non-retracted miss; ≥1 persisted action sau prompt / eligible. Báo prompt coverage viewed/eligible riêng; không đổi mẫu số thành chỉ người đã xem |
| Recovery action completion ≥30% | Subject/week đã viewed prompt; ≥1 reschedule/short action fulfilled bằng valid activity trong 7d từ first view / viewed; rest acknowledgment riêng, không tính fulfillment |
| Return within 7d ≥35% | Subject/week first eligible non-retracted miss; ≥1 valid activity actual end trong (miss deadline, deadline+7d] / eligible mature; không đếm backdated activity trước deadline |
| Annoyance opt-out <10% | Subjects đã bật reminders, có ít nhất một due notification intent, đủ 28d theo dõi; explicit disabled với reason=annoyance / exposed-intent subjects. Intent chỉ proxy exposure, báo delivery/tap evidence coverage; denial/unspecified không gộp |
| Share thử ≥20% | Subjects accepted share experiment / distinct invited; mở share sheet là tried, không chứng minh đã gửi; self-report chia sẻ thật báo riêng |
| Rule suitability ≥60%, acceptance ≥30% | Suitable / participants có feedback (kèm response rate); accepted suggestions / distinct suggestions shown; safety scenarios không lỗi nghiêm trọng, review bởi người phụ trách |

Health rest dừng prompts và loại khỏi eligibility từ thời điểm pause, nhưng không
retroactively xóa missed trước pause hoặc giảm weekly target. Chỉ gửi generic eligibility
boolean, không lý do sức khỏe. Recovery observation chưa đủ 7 ngày bị right-censored.
Action đổi/superseded không được tính hoàn thành nếu link không còn active. Một activity
có thể chứng minh return nhưng chỉ fulfill action liên kết, không fulfill mọi episode.

Ngưỡng là giả định roadmap; report numerator/denominator, cohort size, consent/queue
coverage và censoring, không chỉ phần trăm. 50–100 người/28 ngày không tự đủ A/B power.
Chưa có dữ liệu: **chưa đo**, không Go hay chứng minh nhân quả.

## Dashboard queries dự thảo (PostgreSQL, chưa có bảng)

Đây là query contract cho projection analytics sau gate, không chạy vào Supabase
hiện tại. `cohort_subjects` một row/subject có t0, consent_complete; `credit_facts`
một row/root sau dedup, revision/correction, có active/valid; `week_facts` là latest
finalized snapshot; `eligible_misses` bỏ retracted và có primary_rank theo subject/week.
Projector xử lý out-of-order theo entity_revision, không thứ tự received_at.

```sql
-- Week-4: LEFT JOIN để người không quay lại vẫn ở mẫu số.
with mature as (
  select subject_id, cohort_id, t0 from cohort_subjects
  where consent_complete and t0 + interval '35 days' <= :as_of
), retained as (
  select m.subject_id, m.cohort_id,
    bool_or(c.credit_root_id is not null) as active_w4
  from mature m left join credit_facts c on c.subject_id = m.subject_id
    and c.active and c.valid
    and c.completed_at >= m.t0 + interval '21 days'
    and c.completed_at < m.t0 + interval '28 days'
  group by m.subject_id, m.cohort_id
)
select cohort_id, count(*) denominator,
  count(*) filter (where active_w4) numerator,
  avg(active_w4::int::numeric) retention
from retained group by cohort_id;

-- Weekly adherence: một row/subject/commitment, không đếm event completion thô.
select cohort_id, count(*) measured_weeks,
  avg(least(1.0, valid_credit_count::numeric / target_at_start)) adherence
from week_facts
where measurement_complete and not partial_week and not transition_week
  and ends_at + interval '14 days' <= :as_of
group by cohort_id;
-- 14d = 7d correction + 7d ingestion. Báo repeat-gap riêng từ expected cohort weeks.

-- Return: dùng first eligible episode/subject/week, không nhân trọng số người miss nhiều.
with mature as (
  select * from eligible_misses where primary_rank = 1
    and deadline_at + interval '14 days' <= :as_of
), outcomes as (
  select m.episode_id, m.cohort_id, exists (
    select 1 from credit_facts c where c.subject_id = m.subject_id
      and c.active and c.valid and c.completed_at > m.deadline_at
      and c.completed_at <= m.deadline_at + interval '7 days'
  ) returned from mature m
)
select cohort_id, count(*) denominator,
  count(*) filter (where returned) numerator, avg(returned::int::numeric) rate
from outcomes group by cohort_id;
```

Funnel query contract: LEFT JOIN first onboarding_started → first completed trong
24h → commitment trong 24h từ t0 → first valid credit trong 7d; distinct subject ở
mỗi bước, vẫn xuất các bước độc lập theo mẫu số bảng KPI, không chỉ conversion nối.
Recovery dashboard LEFT JOIN eligible_misses → first exposure → selected action →
active fulfillment, kèm rest/opt-out và expired window. PR1/PR6 phải có fixture SQL
cho duplicate, reordered correction, zero activity, late consent, right-censoring;
queries ở PR0 chưa được thực thi và không chứng nhận backend.

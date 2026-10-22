import { handle, run } from "./worker.ts";

// Edge Runtime entry point. Unit tests import worker.ts without starting HTTP.
if (Deno.args.includes("--once")) console.log(await run());
else Deno.serve(handle);

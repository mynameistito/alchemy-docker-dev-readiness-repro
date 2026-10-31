import { Container, Worker, providers } from "@alchemy.run/cloudflare";
import { Stack, localState } from "alchemy";
import { Effect } from "effect";

const container = Container("example-container", {
  className: "ExampleContainer",
  context: ".",
  dockerfile: "Dockerfile",
  ports: [{ name: "http", port: 8080 }],
});
const containerWorker = Worker("example-container-worker", {
  main: "./container-worker.ts",
  compatibility: { date: "2026-10-30" },
  dev: { port: 14338, strictPort: true },
  env: { CONTAINER: container },
});
const healthyWorker = Worker("example-healthy-worker", {
  main: "./healthy-worker.ts",
  compatibility: { date: "2026-10-30" },
  dev: { port: 14337, strictPort: true },
});
export default Stack("docker-readiness-repro", {
  providers: providers(), state: localState(),
}, Effect.gen(function* () {
  const healthy = yield* healthyWorker;
  yield* containerWorker;
  return { url: healthy.url };
}));

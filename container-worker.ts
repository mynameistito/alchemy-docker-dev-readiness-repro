import { Container } from "@cloudflare/containers";
export class ExampleContainer extends Container {
  defaultPort = 8080;
}
export default {
  fetch() { return new Response("container worker started"); },
};

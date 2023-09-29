import React from "react";
import { createRoot } from "react-dom/client";
import {
  createInertiaApp,
  InertiaAppOptionsForCSR,
} from "@inertiajs/inertia-react";

const pages = import.meta.glob("./pages/*/*.jsx")

const app = () =>
  createInertiaApp<InertiaAppOptionsForCSR<unknown>>({
    resolve: async (name) => {
      document.getElementById('app').classList.add('d-flex', 'flex-column', 'h-100')
      const module = await pages[`./pages/${name}/index.jsx`]()
      const page = (
        module as never as { default: { layout: React.ReactFragment } }
      ).default;
      return page;
    },
    setup({ el, App, props }) {
      const container = document.getElementById(el.id);
      const root = createRoot(container!);
      root.render(<App {...props} />);
    },
  })

document.addEventListener('DOMContentLoaded', () => {
  app();
})

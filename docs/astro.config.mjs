
// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://lokalise.github.io',
  base: '/ruby-lokalise-api-next',
  integrations: [
    starlight({
      title: 'Lokalise Ruby SDK',

      customCss: ['./src/styles/custom.css'],

      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/lokalise/ruby-lokalise-api-next',
        },
      ],

      sidebar: [
        {
          label: 'Getting started',
          items: [
            { label: 'Overview', slug: '' },
          ],
        },
        {
          label: 'Vantage API',
          items: [
            { autogenerate: { directory: 'vantage' } },
          ],
        },
        // Enable this group when Expert documentation is added.
        // {
        //   label: 'Expert API',
        //   items: [
        //     { autogenerate: { directory: 'expert' } },
        //   ],
        // },
      ],
    }),
  ],
});

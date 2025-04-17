import type { MetadataRoute } from 'next'
 
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'Split My Bills',
    short_name: 'Split',
    description: 'A Progressive Web App for Splitting bills among friends',
    start_url: '/',
    display: 'standalone',
    background_color: '#EADBC8',
    theme_color: '#102C57',
    icons: [
      {
        src: '/images/favicon.png',
        sizes: '192x192',
        type: 'image/png',
      },
    ],
  }
}
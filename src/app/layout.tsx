import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.scss";
import { ConfigProvider } from 'antd';

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  metadataBase: new URL(`https://split-the-bill.vercel.app/`),
  title: 'Split the Bill',
  description: 'Split the bills among your friends with ease. Share the amounts and items with your friends.',
  alternates: {
    canonical: '/',
    languages: {
      'en-US': '/en-US',
    },
  },
  icons: `/images/split-bills.png`,
  openGraph: {
    title: 'Split the Bill',
    description: 'Split the bills among your friends with ease. Share the amounts and items with your friends.',
    url: '/',
    siteName: 'Split the Bill',
    images: [
      {
        url: `/images/split-bills.png`, // Must be an absolute URL
        width: 800,
        height: 600,
        alt: 'Split the bills among your friends with ease. Share the amounts and items with your friends.',
      },
      {
        url: `/images/split-bills.png`, // Must be an absolute URL
        width: 1800,
        height: 1600,
        alt: 'Split the bills among your friends with ease. Share the amounts and items with your friends.',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
      </head>
      <ConfigProvider
        theme={{
          token: {
            colorPrimary: '#102C57',
          },
        }}>
        <body className={inter.className}>{children}</body>
      </ConfigProvider>
    </html>
  );
}

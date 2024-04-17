import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.scss";
import { ConfigProvider } from 'antd';

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Split the Bills",
  description: "Split the Bills is a simple web app to split the bills among friends. It helps to calculate the amount each person has to pay based on the items they have shared.",
};

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

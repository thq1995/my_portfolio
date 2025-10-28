import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Tuan Quang - AI Engineer Portfolio',
  description: 'AI Engineer specializing in machine learning, deep learning, and NLP. Building intelligent systems that make an impact.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className="bg-gray-50 text-gray-900 antialiased">{children}</body>
    </html>
  );
}

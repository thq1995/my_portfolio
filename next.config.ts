import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  output: 'export',
  ...(process.env.PAGES_BASE_PATH && { basePath: process.env.PAGES_BASE_PATH }),
};

export default nextConfig;

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    swcMinify: true,
    output: 'standalone', // Important for Docker deployment
    images: {
      unoptimized: true, // If you want to disable image optimization
    },
  }
  
  module.exports = nextConfig
import AnimatedBackground from './AnimatedBackground';

export default function Hero() {
  return (
    <section className="relative h-screen flex items-center justify-center bg-gradient-to-br from-cyan-500 via-teal-600 to-emerald-600 overflow-hidden">
      <AnimatedBackground />
      <div className="absolute inset-0 bg-black/10"></div>
      <div className="relative z-10 text-center text-white px-4 max-w-4xl mx-auto">
        <h1 className="text-5xl md:text-7xl font-bold mb-6 animate-fade-in">
          Hi, I'm <span className="text-amber-300">Tuan Quang</span>
        </h1>
        <p className="text-xl md:text-2xl mb-8 text-gray-50">
          AI Engineer | Building Intelligent Systems with Machine Learning
        </p>
        <div className="flex gap-4 justify-center flex-wrap">
          <a
            href="#projects"
            className="px-8 py-3 bg-amber-400 text-gray-900 font-semibold rounded-full hover:bg-amber-300 transition-all transform hover:scale-105 shadow-lg"
          >
            View My Work
          </a>
          <a
            href="#contact"
            className="px-8 py-3 border-2 border-white text-white font-semibold rounded-full hover:bg-white hover:text-teal-600 transition-all transform hover:scale-105"
          >
            Get In Touch
          </a>
        </div>
      </div>
      <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2 animate-bounce">
        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
        </svg>
      </div>
    </section>
  );
}

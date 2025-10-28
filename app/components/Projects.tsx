import ProjectCard from './ProjectCard';

const projectsData = [
  {
    title: 'AI Chatbot Assistant',
    description: 'Intelligent chatbot powered by LLMs with RAG capabilities for context-aware conversations.',
    tags: [
      { name: 'LangChain', color: 'cyan' },
      { name: 'OpenAI', color: 'emerald' },
      { name: 'FastAPI', color: 'teal' },
    ],
    gradient: 'bg-gradient-to-br from-cyan-400 to-teal-500',
    demoLink: '#',
    githubLink: '#',
  },
  {
    title: 'Computer Vision Pipeline',
    description: 'Real-time object detection and tracking system using YOLO and deep learning models.',
    tags: [
      { name: 'PyTorch', color: 'amber' },
      { name: 'OpenCV', color: 'orange' },
      { name: 'YOLO', color: 'lime' },
    ],
    gradient: 'bg-gradient-to-br from-amber-400 to-orange-500',
    demoLink: '#',
    githubLink: '#',
  },
  {
    title: 'Sentiment Analysis API',
    description: 'NLP service for analyzing sentiment in text with support for multiple languages and emotions.',
    tags: [
      { name: 'Transformers', color: 'teal' },
      { name: 'BERT', color: 'emerald' },
      { name: 'FastAPI', color: 'cyan' },
    ],
    gradient: 'bg-gradient-to-br from-emerald-400 to-cyan-500',
    demoLink: '#',
    githubLink: '#',
  },
];

export default function Projects() {
  return (
    <section id="projects" className="py-20 px-4 bg-gray-100">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-4xl font-bold text-center mb-12 text-gray-800">
          Featured Projects
        </h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {projectsData.map((project, index) => (
            <ProjectCard key={index} {...project} />
          ))}
        </div>
      </div>
    </section>
  );
}

interface ProjectCardProps {
  title: string;
  description: string;
  tags: Array<{ name: string; color: string }>;
  gradient: string;
  demoLink?: string;
  githubLink?: string;
}

export default function ProjectCard({
  title,
  description,
  tags,
  gradient,
  demoLink = '#',
  githubLink = '#',
}: ProjectCardProps) {
  const tagColorClasses: Record<string, string> = {
    cyan: 'bg-cyan-100 text-cyan-700',
    teal: 'bg-teal-100 text-teal-700',
    emerald: 'bg-emerald-100 text-emerald-700',
    amber: 'bg-amber-100 text-amber-700',
    orange: 'bg-orange-100 text-orange-700',
    lime: 'bg-lime-100 text-lime-700',
  };

  return (
    <div className="bg-white rounded-lg overflow-hidden shadow-lg hover:shadow-2xl transition-all transform hover:-translate-y-2">
      <div className={`h-48 ${gradient}`}></div>
      <div className="p-6">
        <h3 className="text-xl font-bold mb-2">{title}</h3>
        <p className="text-gray-600 mb-4">{description}</p>
        <div className="flex flex-wrap gap-2 mb-4">
          {tags.map((tag, index) => (
            <span
              key={index}
              className={`px-3 py-1 rounded-full text-sm ${tagColorClasses[tag.color]}`}
            >
              {tag.name}
            </span>
          ))}
        </div>
        <div className="flex gap-4">
          <a href={demoLink} className="text-teal-600 hover:text-teal-800 font-semibold">
            Live Demo →
          </a>
          <a href={githubLink} className="text-gray-600 hover:text-gray-800 font-semibold">
            GitHub →
          </a>
        </div>
      </div>
    </div>
  );
}

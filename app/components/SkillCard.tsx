interface SkillCardProps {
  title: string;
  skills: string[];
  color: string;
}

export default function SkillCard({ title, skills, color }: SkillCardProps) {
  const colorClasses: Record<string, string> = {
    cyan: 'text-cyan-600',
    teal: 'text-teal-600',
    amber: 'text-amber-600',
    emerald: 'text-emerald-600',
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-lg hover:shadow-xl transition-shadow">
      <h3 className={`font-bold text-xl mb-2 ${colorClasses[color]}`}>
        {title}
      </h3>
      <ul className="text-gray-700 space-y-1">
        {skills.map((skill, index) => (
          <li key={index}>{skill}</li>
        ))}
      </ul>
    </div>
  );
}

import SkillCard from './SkillCard';

const skillsData = [
  {
    title: 'ML/DL',
    skills: ['TensorFlow', 'PyTorch', 'Scikit-learn', 'Keras'],
    color: 'cyan',
  },
  {
    title: 'NLP & LLMs',
    skills: ['Transformers', 'LangChain', 'OpenAI API', 'Hugging Face'],
    color: 'teal',
  },
  {
    title: 'MLOps',
    skills: ['MLflow', 'Docker', 'Kubernetes', 'FastAPI'],
    color: 'amber',
  },
  {
    title: 'Data & Cloud',
    skills: ['Python', 'Pandas / NumPy', 'AWS / GCP', 'PostgreSQL'],
    color: 'emerald',
  },
];

export default function About() {
  return (
    <section className="py-20 px-4 max-w-6xl mx-auto">
      <h2 className="text-4xl font-bold text-center mb-12 text-gray-800">
        About Me
      </h2>
      <div className="grid md:grid-cols-2 gap-12 items-center">
        <div>
          <p className="text-lg text-gray-700 mb-4">
            I'm a passionate AI Engineer specializing in machine learning, deep learning, and natural language processing.
            I transform complex data into intelligent solutions that drive real-world impact.
          </p>
          <p className="text-lg text-gray-700">
            When I'm not training models, you can find me researching the latest AI papers, contributing to open-source ML projects,
            or sharing insights about AI/ML with the tech community.
          </p>
        </div>
        <div className="grid grid-cols-2 gap-4">
          {skillsData.map((skill, index) => (
            <SkillCard
              key={index}
              title={skill.title}
              skills={skill.skills}
              color={skill.color}
            />
          ))}
        </div>
      </div>
    </section>
  );
}

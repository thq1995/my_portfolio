interface SocialLinkProps {
  href: string;
  icon: React.ReactNode;
  label: string;
}

export default function SocialLink({ href, icon, label }: SocialLinkProps) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="flex items-center gap-2 px-6 py-3 bg-amber-400 text-gray-900 rounded-full font-semibold hover:bg-amber-300 transition-all transform hover:scale-105 shadow-lg"
    >
      {icon}
      {label}
    </a>
  );
}

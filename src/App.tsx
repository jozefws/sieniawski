import { useEffect, useRef, useState } from 'react';
import { about, site, skills } from './data';

const sections = [
  { id: 'about', label: 'About' },
  { id: 'contact', label: 'Contact' },
] as const;

function Arrow() {
  return (
    <svg viewBox="0 0 16 16" width="1em" height="1em" aria-hidden="true" fill="none">
      <path d="M3 13 13 3M5.5 3H13v7.5" stroke="currentColor" strokeWidth="1.6" strokeLinecap="square" />
    </svg>
  );
}

function Spotlight() {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const fine = window.matchMedia('(hover: hover) and (pointer: fine)');
    const still = window.matchMedia('(prefers-reduced-motion: reduce)');
    if (!fine.matches || still.matches) return;

    let raf = 0;
    let tx = window.innerWidth / 2;
    let ty = window.innerHeight / 3;
    let x = tx;
    let y = ty;

    const step = () => {
      x += (tx - x) * 0.08;
      y += (ty - y) * 0.08;
      el.style.setProperty('--x', `${x}px`);
      el.style.setProperty('--y', `${y}px`);
      raf = requestAnimationFrame(step);
    };
    const move = (e: PointerEvent) => {
      tx = e.clientX;
      ty = e.clientY;
    };

    window.addEventListener('pointermove', move, { passive: true });
    raf = requestAnimationFrame(step);
    return () => {
      window.removeEventListener('pointermove', move);
      cancelAnimationFrame(raf);
    };
  }, []);

  return <div ref={ref} className="spotlight" aria-hidden="true" />;
}

export default function App() {
  const [active, setActive] = useState<string>('');

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
        if (visible) setActive(visible.target.id);
      },
      { rootMargin: '-40% 0px -50% 0px', threshold: [0, 0.2, 0.5] },
    );
    for (const { id } of sections) {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    }
    return () => observer.disconnect();
  }, []);

  return (
    <>
      <a className="skip-link" href="#about">
        Skip to content
      </a>
      <Spotlight />
      <div className="grain" aria-hidden="true" />

      <header className="site-header">
        <a className="brand" href="#top" aria-label="Back to top">
          S<span className="brand-dot">.</span>
        </a>
        <nav aria-label="Sections">
          {sections.map(({ id, label }) => (
            <a key={id} href={`#${id}`} className={active === id ? 'active' : ''}>
              {label}
            </a>
          ))}
        </nav>
      </header>

      <main id="top">
        <section className="hero" aria-label="Introduction">
          <h1 className="wordmark" translate="no">
            {[...site.wordmark].map((letter, i) => (
              <span key={i} style={{ '--i': i } as React.CSSProperties}>
                {letter}
              </span>
            ))}
          </h1>
          <div className="hero-foot">
            <span className="mono">{site.location}</span>
            <span className="mono scroll-hint" aria-hidden="true">
              Scroll ↓
            </span>
            <span className="hero-links">
              <a className="mono" href={site.github} target="_blank" rel="noreferrer">
                GitHub <Arrow />
              </a>
              <a className="mono" href={`mailto:${site.email}`}>
                Email <Arrow />
              </a>
            </span>
          </div>
        </section>

        <section id="about" aria-labelledby="about-title">
          <div className="section-head">
            <span className="mono index">01</span>
            <h2 id="about-title">About</h2>
          </div>
          <div className="about-grid">
            <div className="about-copy">
              {about.map((paragraph) => (
                <p key={paragraph}>{paragraph}</p>
              ))}
            </div>
            <ul className="skills" aria-label="Skills">
              {skills.map((skill) => (
                <li key={skill} className="mono">
                  {skill}
                </li>
              ))}
            </ul>
          </div>
        </section>

        <section id="contact" aria-labelledby="contact-title">
          <div className="section-head">
            <span className="mono index">02</span>
            <h2 id="contact-title">Contact</h2>
          </div>
          <p className="mono contact-status">
            <span className="status-dot" aria-hidden="true" />
            {site.availability}
          </p>
          <a className="contact-email" href={`mailto:${site.email}`}>
            {site.email}
            <Arrow />
          </a>
        </section>
      </main>

      <footer>
        <span className="mono">
          © {new Date().getFullYear()} {site.name}
        </span>
        <a className="mono" href={site.github} target="_blank" rel="noreferrer">
          Source on GitHub <Arrow />
        </a>
      </footer>
    </>
  );
}

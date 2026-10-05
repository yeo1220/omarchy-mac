const demo = document.querySelector('[data-workspace]');
if (demo) {
  const buttons = [...demo.querySelectorAll('[data-space]')];
  const scenes = {
    1: ['01', '워크스페이스 1 예시', '터미널과 편집기를 나란히.', 'Ghostty'],
    2: ['02', '워크스페이스 2 예시', '브라우저를 넓게, 참고 창은 옆에.', 'Google Chrome'],
    3: ['03', '워크스페이스 3 예시', '작업 창과 사용량 확인을 한 공간에.', 'Cursor']
  };
  const hint = document.querySelector('[data-demo-hint]');
  if (hint) hint.textContent = '위의 1 · 2 · 3을 눌러 보세요.';
  buttons.forEach(button => {
    button.disabled = false;
    button.addEventListener('click', () => {
    const number = button.dataset.space;
    const scene = scenes[number];
    demo.dataset.workspace = number;
    buttons.forEach(item => item.setAttribute('aria-pressed', String(item === button)));
    demo.querySelector('[data-scene-number]').textContent = scene[0];
    demo.querySelector('[data-scene-title]').textContent = scene[1];
    demo.querySelector('[data-scene-copy]').textContent = scene[2];
    demo.querySelector('[data-current-app]').textContent = scene[3];
    const grid = demo.querySelector('.hero-grid');
    grid.classList.remove('is-switching');
    void grid.offsetWidth;
    grid.classList.add('is-switching');
    });
  });
}

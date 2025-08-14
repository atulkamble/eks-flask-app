async function loadInfo() {
  const infoEl = document.getElementById('info');
  infoEl.textContent = 'Loading...';
  try {
    const res = await fetch('/');
    const data = await res.json();
    infoEl.textContent = JSON.stringify(data, null, 2);
  } catch (e) {
    infoEl.textContent = 'Failed to load: ' + e;
  }
}

document.getElementById('refresh').addEventListener('click', loadInfo);

document.getElementById('echoForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const out = document.getElementById('echoOut');
  out.textContent = 'Sending...';
  try {
    const body = document.getElementById('payload').value || '{}';
    const res = await fetch('/api/echo', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body
    });
    const data = await res.json();
    out.textContent = JSON.stringify(data, null, 2);
  } catch (err) {
    out.textContent = 'Error: ' + err;
  }
});

// initial load
loadInfo();

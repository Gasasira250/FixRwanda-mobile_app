const API = `${location.origin}/api`;
let token = localStorage.getItem('fr_admin_token') || '';

const loginView = document.getElementById('login');
const appView = document.getElementById('app');
const loginError = document.getElementById('login-error');

async function request(path, options = {}) {
  const response = await fetch(`${API}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: token ? `Bearer ${token}` : '',
      ...(options.headers || {}),
    },
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(body.message || 'Request failed');
  return body;
}

function showApp() {
  loginView.classList.add('hidden');
  appView.classList.remove('hidden');
  load();
}

function showLogin() {
  appView.classList.add('hidden');
  loginView.classList.remove('hidden');
}

document.getElementById('signin').onclick = async () => {
  loginError.textContent = '';
  try {
    const body = await request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        identifier: document.getElementById('email').value,
        password: document.getElementById('password').value,
      }),
    });
    if (body.user.role !== 'admin') throw new Error('Admin account required.');
    token = body.token;
    localStorage.setItem('fr_admin_token', token);
    showApp();
  } catch (error) {
    loginError.textContent = error.message;
  }
};

document.getElementById('signout').onclick = () => {
  token = '';
  localStorage.removeItem('fr_admin_token');
  showLogin();
};

async function setStatus(id, verificationStatus) {
  await request(`/admin/professionals/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ verificationStatus }),
  });
  load();
}

async function load() {
  const [stats, pros, bookings] = await Promise.all([
    request('/admin/stats'),
    request('/admin/professionals'),
    request('/admin/bookings'),
  ]);
  document.getElementById('stats').innerHTML = [
    ['Users', stats.users],
    ['Professionals', stats.professionals],
    ['Pending ID/TVET', stats.pendingVerifications],
    ['Bookings', stats.bookings],
    ['Revenue', `${Number(stats.revenueRwf).toLocaleString()} RWF`],
    ['Store', stats.store],
  ]
    .map(
      ([label, value]) =>
        `<article class="stat"><strong>${value}</strong><span>${label}</span></article>`,
    )
    .join('');

  document.getElementById('pros').innerHTML = pros.professionals
    .map((item) => {
      const klass =
        item.verificationStatus === 'verified'
          ? 'ok'
          : item.verificationStatus === 'rejected'
            ? 'err'
            : 'wait';
      return `<article class="card">
        <div class="row">
          <div>
            <strong>${item.name}</strong>
            <div>${item.trade} • ${item.location}</div>
          </div>
          <span class="badge ${klass}">${item.verificationStatus}</span>
        </div>
        <p>TVET: ${item.tvetVerified} • ID: ${item.idVerified} • ${Number(item.serviceFeeRwf).toLocaleString()} RWF</p>
        <div class="actions">
          <button onclick="setStatus('${item.id}','verified')">Verify</button>
          <button onclick="setStatus('${item.id}','rejected')">Reject</button>
        </div>
      </article>`;
    })
    .join('');

  document.getElementById('bookings').innerHTML = (bookings.bookings || [])
    .map(
      (item) => `<article class="card">
        <div class="row">
          <strong>${item.id}</strong>
          <span class="badge ${item.status === 'cancelled' ? 'err' : 'ok'}">${item.status}</span>
        </div>
        <div>${item.professionalName} • ${item.service}</div>
        <div>${item.paymentMethod} • ${Number(item.serviceFeeRwf).toLocaleString()} RWF</div>
      </article>`,
    )
    .join('') || '<p>No bookings yet.</p>';
}

window.setStatus = setStatus;
if (token) showApp();

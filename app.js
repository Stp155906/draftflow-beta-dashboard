const dialog = document.querySelector('#setupModal');
const title = document.querySelector('#modalTitle');
const text = document.querySelector('#modalText');
const toast = document.querySelector('#toast');

const modalCopy = {
  folder: ['Choose your content folder', 'In the working beta, this opens Google Drive so you can select one parent folder. DraftFlow will only check the folder you choose.'],
  tiktok: ['Connect your TikTok', 'In the working beta, this securely opens TikTok approval. You choose which TikTok account receives the drafts.'],
  schedule: ['Set your delivery time', 'In the working beta, choose one or two daily draft windows. You can change or pause them whenever you need.'],
};

document.querySelectorAll('[data-modal]').forEach(button => button.addEventListener('click', () => {
  const [heading, body] = modalCopy[button.dataset.modal];
  title.textContent = heading;
  text.textContent = body;
  dialog.showModal();
}));
document.querySelectorAll('.close, .close-modal').forEach(button => button.addEventListener('click', () => dialog.close()));

document.querySelector('#simulateCheck').addEventListener('click', () => {
  toast.textContent = 'Preview check started - the working beta will inspect today’s folder.';
  toast.classList.add('show');
  window.setTimeout(() => toast.classList.remove('show'), 3600);
});

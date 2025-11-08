import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['label', 'close'];

  connect() {
    // Listen for clicks on funnel links inside this dropdown
    const funnelLinks = this.element.querySelectorAll('[data-funnel-link]');
    funnelLinks.forEach(link => {
      link.addEventListener('click', () => {
        this.highlightDropdown();
      });
    });
  }

  setLabel(event) {
    this.labelTarget.innerText = event.target.innerText;
    this.closeTarget.classList.add('hidden');
  }

  removeHidden(event) {
    this.closeTarget.classList.remove('hidden');
  }

  highlightDropdown() {
    // Find the dropdown label and highlight it
    const dropdownLabel = this.element.querySelector('[data-funnel-dropdown-label]');
    
    // Remove active state from all turbo-frame links
    const frame = dropdownLabel.dataset.turboFrame;
    const otherLinks = document.querySelectorAll(`[data-turbo-frame="${frame}"]`);
    otherLinks.forEach(link => {
      link.classList.remove('text-primary', 'font-semibold');
    });
    
    // Add active state to dropdown label
    dropdownLabel.classList.add('text-primary', 'font-semibold');
  }
}

import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    data: Array,
    label: String
  }

  connect() {
    // Wait for Chart.js to be available
    if (typeof Chart === 'undefined') {
      console.error('Chart.js not loaded for sparkline:', this.labelValue);
      // Try again after a short delay
      setTimeout(() => this.renderChart(), 100);
      return;
    }
    
    this.renderChart();
  }

  renderChart() {
    if (typeof Chart === 'undefined') {
      console.error('Chart.js still not available for:', this.labelValue);
      return;
    }

    try {
      // Generate sample trend data (in production, pass real data via data-sparkline-data-value)
      const data = this.hasDataValue ? this.dataValue : Array.from({length: 7}, () => Math.random() * 100);
      
      new Chart(this.element.getContext('2d'), {
        type: 'line',
        data: {
          labels: data.map((_, i) => i),
          datasets: [{
            data: data,
            borderColor: 'rgba(99, 102, 241, 0.8)',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            borderWidth: 2,
            fill: true,
            tension: 0.4,
            pointRadius: 0
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { 
            legend: { display: false }, 
            tooltip: { enabled: false } 
          },
          scales: {
            x: { display: false },
            y: { display: false }
          }
        }
      });
      console.log('Sparkline created for:', this.labelValue);
    } catch (e) {
      console.error('Error creating sparkline for', this.labelValue, ':', e);
    }
  }
}


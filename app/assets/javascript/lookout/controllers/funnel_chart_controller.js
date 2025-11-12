import { Controller } from '@hotwired/stimulus';
// NOTE: chartjs-plugin-datalabels is imported globally in application.js
// Do NOT import it here - it causes race conditions with Chart.js initialization
import { getCSS, externalTooltipHandler } from "helpers/chart_utils";

const calculatePercentageDifference = function(oldValue, newValue) {
  if(!oldValue) { return false }
  if (oldValue == 0 && newValue > 0) {
    return 100
  } else if (oldValue == 0 && newValue == 0) {
    return 0
  } else {
    return Math.round((newValue - oldValue) / oldValue * 100)
  }
}

export default class extends Controller {
  connect() {
    this.funnel = JSON.parse(this.element.dataset.data);
    console.log('Funnel data:', this.funnel);

    // Check if Chart.js is available
    if (typeof window.Chart === 'undefined') {
      console.error('Chart.js is not loaded yet');
      return;
    }

    // Register ChartDataLabels plugin globally if available
    if (window.ChartDataLabels && !window.Chart.registry.plugins.get('datalabels')) {
      window.Chart.register(window.ChartDataLabels);
    }

    const fontFamily = 'ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"';
    const labels = this.funnel.steps.map((step) => step.name);
    const stepData = this.funnel.steps.map((step) => step.total_events);
    
    // Calculate conversion rates as percentages for each step
    const conversionRates = this.funnel.steps.map((step, index) => {
      if (index === 0 || !step.drop_off) return 100;
      return (step.drop_off * 100).toFixed(1);
    });

    const data = {
      labels,
      datasets: [
        {
          label: 'Events',
          data: stepData,
          borderRadius: 4,
          backgroundColor: getCSS('--p'),
          borderColor: getCSS('--p'),
          borderWidth: 2,
          barPercentage: 0.8,
          categoryPercentage: 0.9,
          maxBarThickness: 120,
        },
      ],
    };

    const config = {
      responsive: true,
      maintainAspectRatio: false,
      type: 'bar',
      data,
      options: {
        layout: {
          padding: { top: 50, bottom: 20, left: 20, right: 80 },
        },
        plugins: {
          legend: false,
          tooltip: {
            enabled: false,
            position: 'nearest',
            external: externalTooltipHandler(this)
          },
          datalabels: {
            anchor: 'center',
            align: 'center',
            borderRadius: 4,
            padding: { top: 6, bottom: 6, right: 8, left: 8 },
            color: getCSS('--bc'),
            font: {
              weight: 'bold',
              size: 14
            },
            clip: false,
            clamp: false,
            formatter: (value, context) => {
              const index = context.dataIndex;
              const rate = conversionRates[index];
              if (index === 0) {
                return value.toLocaleString();
              }
              return `${value.toLocaleString()}\n(${rate}%)`;
            },
            textAlign: 'center',
          },
        },
        scales: {
          y: { 
            display: true,
            border: { display: false },
            grid: { 
              drawBorder: false, 
              display: true,
              color: 'rgba(255, 255, 255, 0.1)'
            },
            ticks: {
              color: getCSS('--bc'),
              callback: (value) => value.toLocaleString()
            }
          },
          x: {
            position: 'bottom',
            display: true,
            border: { display: false },
            grid: { drawBorder: false, display: false },
            ticks: {
              padding: 8,
              color: getCSS('--bc'),
              font: {
                size: 13,
                weight: '500'
              }
            },
          },
        },
      },
    };

    const visitorsData = [];

    this.chart = new window.Chart(
      this.element,
      config,
    );
  }

  formatLabel(label) {
    return label
  }

  formatMetric(metric) {
    return metric
  }


  extractTooltipData(tooltip) {
    const stepIndex = this.funnel.steps.findIndex(step => step.name === tooltip.title[0]);
    const data = this.funnel.steps[stepIndex];

    const value = data.total_events;
    const uniqueVisits = data.unique_visits;
    const conversionRate = stepIndex > 0 && data.drop_off ? 
      `${(data.drop_off * 100).toFixed(1)}% of previous` : 
      '100%';

    return {
      comparison: true,
      comparisonDifference: false,
      metric: tooltip.title[0],
      label: "Total Events",
      labelBackgroundColor: getCSS('--p'),
      formattedValue: value.toLocaleString(),
      comparisonLabel: "Unique Visits",
      comparisonLabelBackgroundColor: getCSS('--s'),
      formattedComparisonValue: `${uniqueVisits.toLocaleString()} (${conversionRate})`,
    }
  }
}

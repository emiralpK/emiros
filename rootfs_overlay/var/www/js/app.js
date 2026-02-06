// EmiROS Dashboard - JavaScript Application

// Configuration
const UPDATE_INTERVAL = 5000; // 5 seconds
const API_ENDPOINT = '/cgi-bin/sysinfo.sh';

// Update dashboard with system info
async function updateDashboard() {
    try {
        const response = await fetch(API_ENDPOINT);
        const data = await response.json();

        // Update CPU Usage
        updateMetric('cpu-usage', data.cpu_usage + '%', 'cpu-progress', data.cpu_usage);

        // Update Memory
        updateMetric('memory-percent', data.memory_percent + '%', 'memory-progress', data.memory_percent);
        document.getElementById('memory-used').textContent = data.memory_used;
        document.getElementById('memory-total').textContent = data.memory_total;

        // Update Disk
        updateMetric('disk-percent', data.disk_percent + '%', 'disk-progress', data.disk_percent);
        document.getElementById('disk-used').textContent = data.disk_used;
        document.getElementById('disk-total').textContent = data.disk_total;

        // Update Uptime
        document.getElementById('uptime').textContent = data.uptime;

        // Update Network Info
        document.getElementById('hostname').textContent = data.hostname;
        document.getElementById('ip-address').textContent = data.ip_address;

        // Update System Info
        document.getElementById('kernel').textContent = data.kernel;
        document.getElementById('load-avg').textContent = data.load_average;

        // Update XFCE Status
        const xfceStatus = document.getElementById('xfce-status');
        const xfceText = document.getElementById('xfce-text');
        if (data.xfce_running) {
            xfceStatus.className = 'status-dot active';
            xfceText.textContent = 'Running';
        } else {
            xfceStatus.className = 'status-dot inactive';
            xfceText.textContent = 'Not Running';
        }

        // Update timestamp
        const now = new Date();
        document.getElementById('last-update').textContent = now.toLocaleTimeString();

    } catch (error) {
        console.error('Failed to fetch system info:', error);
        // Show error state
        document.getElementById('last-update').textContent = 'Error updating';
    }
}

// Update metric value and progress bar
function updateMetric(valueId, value, progressId, percent) {
    const valueElement = document.getElementById(valueId);
    const progressElement = document.getElementById(progressId);

    valueElement.textContent = value;
    progressElement.style.width = percent + '%';

    // Change color based on usage
    progressElement.className = 'progress-fill';
    if (percent > 90) {
        progressElement.classList.add('danger');
    } else if (percent > 70) {
        progressElement.classList.add('warning');
    }
}

// Initialize dashboard
function init() {
    // Initial update
    updateDashboard();

    // Set up periodic updates
    setInterval(updateDashboard, UPDATE_INTERVAL);

    // Add loading animation
    document.querySelector('.stats-grid').classList.add('loading');
}

// Start when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}

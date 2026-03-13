let currentJobId = null;
let monitorInterval = null;

async function runTests() {
  const format = document.getElementById("format").value;

  const res = await fetch("/api/tests/run", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ format }),
  });

  const { jobId } = await res.json();

  /* stop any existing polling */
  if (monitorInterval) {
    clearInterval(monitorInterval);
  }

  currentJobId = jobId;

  document.getElementById("progressBox").style.display = "block";
  document.getElementById("progress").innerText = "0";
  document.getElementById("cancelBtn").style.display = "inline-block";

  monitor(jobId);
}

function monitor(jobId) {
  monitorInterval = setInterval(async () => {
    try {
      const res = await fetch(`/api/tests/status/${jobId}`);
      const job = await res.json();

      document.getElementById("progress").innerText = job.progress || 0;

      if (job.state === "completed") {
        clearInterval(monitorInterval);
        monitorInterval = null;

        document.getElementById("cancelBtn").style.display = "none";

        window.open(job.result.reportFile);
        loadReports();
      }

      if (job.state === "failed") {
        clearInterval(monitorInterval);
        monitorInterval = null;

        alert("Test failed");
      }
    } catch (err) {
      console.error(err);
    }
  }, 2000);
}

async function cancelJob() {
  if (!currentJobId) return;

  await fetch(`/api/tests/cancel/${currentJobId}`, {
    method: "DELETE",
  });

  if (monitorInterval) {
    clearInterval(monitorInterval);
    monitorInterval = null;
  }

  document.getElementById("progress").innerText = "0";
  document.getElementById("progressBox").style.display = "none";
  document.getElementById("cancelBtn").style.display = "none";

  currentJobId = null;
}

async function loadReports() {
  const res = await fetch("/api/tests/reports");
  const reports = await res.json();

  const tree = document.getElementById("reportTree");
  tree.innerHTML = "";

  reports.forEach((folder) => {
    const li = document.createElement("li");

    const link = document.createElement("a");
    link.href = `/reports/runs/${folder}/index.html`;
    link.target = "_blank";
    link.textContent = folder;

    li.appendChild(link);
    tree.appendChild(li);
  });
}

loadReports();

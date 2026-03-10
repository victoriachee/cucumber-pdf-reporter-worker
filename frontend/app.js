async function runTests() {
  const format = document.getElementById("format").value;

  await fetch("/api/tests/run", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ format }),
  });

  loadReports();
}

async function loadReports() {
  const res = await fetch("/api/tests/reports");
  const reports = await res.json();

  const tree = document.getElementById("reportTree");
  tree.innerHTML = "";

  reports.forEach((file) => {
    const li = document.createElement("li");

    const link = document.createElement("a");
    link.href = `/reports/${file}`;
    link.target = "_blank";
    link.textContent = file;

    li.appendChild(link);
    tree.appendChild(li);
  });
}

loadReports();

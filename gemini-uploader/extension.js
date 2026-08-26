const vscode = require("vscode");

function activate(context) {
  let disposable = vscode.commands.registerCommand("geminiUploader.open", () => {
    const panel = vscode.window.createWebviewPanel(
      "repoViewer",
      "GitHub Raw Viewer + Gemini",
      vscode.ViewColumn.One,
      { enableScripts: true }
    );

    panel.webview.html = getWebviewContent();
  });

  context.subscriptions.push(disposable);
}

function getWebviewContent() {
  return `
<!DOCTYPE html>
<html lang="ja">
<head>
<meta http-equiv="Content-Security-Policy" content="
  default-src 'none';
  img-src https: data:;
  script-src 'unsafe-inline';
  style-src 'unsafe-inline';
  connect-src https:;
">
</head>

<body>
  <h2>GitHub リポジトリの Raw 一覧（固定: 23tk/Git）</h2>

  <button onclick="loadAllFiles()">全ファイルを読み込む</button>

  <h3>ステータス</h3>
  <pre id="status"></pre>

  <h3>読み込んだファイル内容</h3>
  <pre id="fileContent"></pre>

  <hr>

  <h2>Gemini に質問する（モデル: gemini-3.6-flash）</h2>
  <textarea id="question" rows="5" style="width:100%;" placeholder="質問を入力"></textarea>
  <br><br>
  <button onclick="sendToGemini()">質問を送信</button>

  <h3>Gemini の返答</h3>
  <pre id="geminiResult"></pre>

<script>
  const apiKey = "AQ.Ab8RN6KE45-zAOiMGbwsXNGltNCss0XZiOzGU8Px6vm5Do8U1A";
  let currentText = "";

  window.onerror = function(message, source, lineno, colno, error) {
    const status = document.getElementById("status");
    status.textContent =
      "JSエラー: " + message + "\\n" +
      "場所: " + source + ":" + lineno + ":" + colno + "\\n" +
      (error ? ("詳細: " + error.stack) : "");
  };

  async function loadAllFiles() {
    const repo = "23tk/Git";
    const url = \`https://api.github.com/repos/\${repo}/contents\`;

    document.getElementById("status").textContent = "ファイル一覧取得中…";

    let res;
    try {
      res = await fetch(url);
    } catch (e) {
      document.getElementById("status").textContent = "ネットワークエラー: " + e;
      return;
    }

    if (!res.ok) {
      document.getElementById("status").textContent =
        "GitHub API エラー: " + res.status + " " + res.statusText;
      return;
    }

    const files = await res.json();
    let combined = "";

    document.getElementById("status").textContent = "全ファイル読み込み中…";

    for (const f of files) {
      if (!f.download_url) continue;

      try {
        const rawRes = await fetch(f.download_url);
        if (!rawRes.ok) continue;

        const text = await rawRes.text();

        combined += \`=== \${f.path} ===\\n\${text}\\n\\n\`;
      } catch (e) {
        combined += \`=== \${f.path} (読み込み失敗) ===\\n\${e}\\n\\n\`;
      }
    }

    currentText = combined;

    document.getElementById("fileContent").textContent = combined;
    document.getElementById("status").textContent = "全ファイル読み込み完了";
  }

  async function sendToGemini() {
    const question = document.getElementById("question").value;

    if (!currentText) {
      document.getElementById("geminiResult").textContent =
        "エラー: ファイル内容が空です。まず全ファイルを読み込んでください。";
      return;
    }

    const response = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent?key=" + apiKey,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            { parts: [{ text: "ファイル内容:\\n" + currentText + "\\n\\n質問:\\n" + question }] }
          ]
        })
      }
    );

    const data = await response.json();
    document.getElementById("geminiResult").textContent =
      JSON.stringify(data, null, 2);
  }
</script>

</body>
</html>
  `;
}

exports.activate = activate;

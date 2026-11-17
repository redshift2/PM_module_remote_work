<!doctype html><html><head><title>Remote Work Manager</title>
<style>.rw{max-width:1250px;margin:25px auto;font-family:system-ui}.rw h1{background:#1767a7;color:white;padding:18px}.rw section{padding:20px;border:1px solid #ddd;margin:18px 0}.rw table{width:100%;border-collapse:collapse}.rw td,.rw th{padding:10px;border-bottom:1px solid #ddd;text-align:left}.rw label{display:block;margin:12px 0}</style></head>
<body><div class="pm-shell" data-pm-theme="dark">
<g:render template="/shared/pmShellStyles"/>
<g:render template="/shared/pmShellSidebar"/>
<div class="pm-main"><g:render template="/shared/pmShellHeader" model="[moduleTitle:'Remote Work Manager']"/>
<main class="pm-content"><style>
.pm-shell .rw{max-width:1250px;margin:0 auto;padding:20px 12px 35px;color:var(--pm-text);font-family:inherit}
.pm-shell .rw section{background:var(--pm-surface);border:1px solid var(--pm-border);border-radius:6px;margin:0 0 20px;padding:0 0 18px;overflow:hidden}
.pm-shell .rw h2{background:var(--pm-sidebar);color:var(--pm-text);padding:15px 18px;margin:0 0 15px;font-size:18px}
.pm-shell .rw section>p,.pm-shell .rw section>form{margin-left:18px;margin-right:18px}
.pm-shell .rw label{display:block;margin:12px 0;color:var(--pm-text)}
.pm-shell .rw input,.pm-shell .rw select{padding:9px;border:1px solid var(--pm-border);border-radius:5px;background:var(--pm-bg);color:var(--pm-text);max-width:100%;margin-left:8px}
.pm-shell .rw input[type=file]{max-width:100%}
.pm-shell .rw button{background:var(--pm-blue);color:#fff;border:1px solid var(--pm-border);border-radius:5px;padding:9px 14px;cursor:pointer}
.pm-shell .rw table{width:100%;border-collapse:collapse}
.pm-shell .rw th,.pm-shell .rw td{padding:11px 13px;text-align:left;border-bottom:1px solid var(--pm-border);color:var(--pm-text)}
.pm-shell .rw th{background:var(--pm-sidebar)}
.pm-shell .rw .rw-table{overflow-x:auto}
.pm-shell .rw a{color:#8bc6ff}.pm-shell[data-pm-theme=light] .rw a{color:#155a99}
.pm-shell .rw .rw-tabs{display:flex;gap:10px;margin:0 0 20px;border-bottom:1px solid var(--pm-border);padding-bottom:10px}
.pm-shell .rw .rw-tabs a{padding:10px 16px;border:1px solid var(--pm-border);border-radius:5px;text-decoration:none}
.pm-shell .rw .rw-tabs a.active{background:var(--pm-blue);color:white}
.pm-shell .rw .rw-danger{background:#bb252b;border-color:#bb252b;color:white;font-weight:700;padding:6px 11px}
.pm-shell .rw .rw-clear{display:inline-flex;align-items:center;gap:8px}
.pm-shell .rw .rw-clear svg{width:17px;height:17px;fill:currentColor}
.pm-shell .rw .rw-inline{display:inline-block;margin:0}
.pm-shell .rw .rw-actions{display:flex;align-items:center;gap:10px}
.pm-shell .rw .rw-alert{padding:12px 16px;border:1px solid var(--pm-border);border-radius:5px;margin-bottom:16px}

.pm-shell .rw a.rw-download{display:inline-flex;align-items:center;justify-content:center;width:34px;height:34px;box-sizing:border-box;background:#1767a7;color:#fff;border:1px solid #1767a7;border-radius:5px;text-decoration:none;vertical-align:middle}
.pm-shell .rw a.rw-download:hover{background:#125587;border-color:#125587;color:#fff}
.pm-shell .rw a.rw-download:focus-visible{outline:2px solid #8bc6ff;outline-offset:2px}
.pm-shell .rw .rw-download svg{width:19px;height:19px;fill:currentColor}

.pm-shell .rw .rw-dropzone{border:2px dashed var(--pm-border);border-radius:8px;padding:25px 18px;text-align:center;cursor:pointer;background:var(--pm-bg);transition:border-color .15s,background .15s}
.pm-shell .rw .rw-dropzone.rw-dragging{border-color:var(--pm-blue);background:rgba(23,103,167,.14)}
.pm-shell .rw .rw-dropzone:focus-visible{outline:2px solid var(--pm-blue);outline-offset:3px}
.pm-shell .rw .rw-dropzone strong{display:block;font-size:16px;margin-bottom:5px}
.pm-shell .rw .rw-dropzone small{display:block;opacity:.8}
.pm-shell .rw .rw-dropzone .rw-file-name{display:block;margin-top:10px;font-weight:600;overflow-wrap:anywhere}
.pm-shell .rw .rw-dropzone .rw-file-error{display:block;color:#e66;margin-top:7px}
.pm-shell .rw .rw-dropzone input[type=file]{position:absolute;width:1px;height:1px;opacity:0;pointer-events:none}
</style><div class="rw">
<g:if test="${flash.error}"><p class="rw-alert" style="color:#e66">${flash.error?.encodeAsHTML()}</p></g:if>
<g:if test="${flash.message}"><p class="rw-alert">${flash.message?.encodeAsHTML()}</p></g:if>
<nav class="rw-tabs" aria-label="Remote Work tabs"><a href="/remoteWork/index?tab=jobs" class="${tab == 'jobs' ? 'active' : ''}">Jobs</a><a href="/remoteWork/index?tab=results" class="${tab == 'results' ? 'active' : ''}">Results</a></nav>
<g:if test="${tab == 'jobs'}">
<section><h2>Submit remote job</h2><p>Server upload limit: ${maxUploadBytes} bytes.</p>
<form action="${request.contextPath}/remoteWork/submit" method="POST" enctype="multipart/form-data">
<label>Worker script <select name="scriptId" id="scriptId" onchange="loadScriptOptions()" required><g:each in="${scripts}" var="s"><option value="${s.id}">${s.name?.encodeAsHTML()} (${s.jobType?.encodeAsHTML()} / ${s.scriptVersion?.encodeAsHTML()})</option></g:each></select></label>
<div id="scriptOptions"></div>
<label>Job description <input type="text" name="jobDescription" maxlength="500" placeholder="Describe the purpose of this job" /></label>
<div class="rw-dropzone" id="rwDropzone" role="button" tabindex="0" aria-label="Choose or drop a ZIP file">
<strong>Drop your ZIP file here</strong><small>or click to browse your computer</small>
<input type="file" id="rwPackage" name="package" accept=".zip,application/zip,application/x-zip-compressed" required aria-label="Input ZIP"/>
<span class="rw-file-name" id="rwFileName" aria-live="polite">No file selected</span>
<span class="rw-file-error" id="rwFileError" role="alert"></span>
</div>
<label>Input file within ZIP <input name="inputFile" placeholder="assembly.step"/></label>
<label>Output filename prefix <input name="outputPrefix" placeholder="assembly_"/></label>
<button type="submit">Submit job</button></form></section>
<section><h2>Jobs</h2>
<form action="${request.contextPath}/remoteWork/clearInactive" method="POST" onsubmit="return confirm('Clear failed and cancelled jobs? Queued and running jobs will be kept.');">
<button type="submit" class="rw-clear" title="Clear failed and cancelled jobs" aria-label="Clear inactive jobs">
<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15.1 2.2 21.8 8.9l-2.1 2.1-2-2-7.9 7.9-4.6-4.6 7.9-7.9-2-2 2-2.2ZM4 17h16v2H4zm0 3h16v2H4z"/></svg>
Clear inactive jobs</button></form><div class="rw-table"><table><thead><tr><th>ID</th><th>Owner</th><th>Type</th><th>Status</th><th>Progress</th><th>Message</th><th>Actions</th></tr></thead><tbody>
<g:each in="${jobs.findAll { it.status != 'COMPLETED' }}" var="j"><tr><td>${j.id}</td><td>${j.submittedBy?.encodeAsHTML()}</td><td>${j.jobType?.encodeAsHTML()}</td><td>${j.status}</td><td>${j.progressPercent}%</td><td>${j.resultMessage?.encodeAsHTML()}</td><td>
<g:if test="${j.status == 'COMPLETED'}"><a href="${request.contextPath}/remoteWork/download/${j.id}">Download ZIP</a></g:if>
<g:if test="${j.status in ['QUEUED','ASSIGNED','RUNNING','UPLOADING_RESULTS']}"><form action="${request.contextPath}/remoteWork/cancel/${j.id}" method="POST"><button type="submit">Cancel</button></form></g:if>
</td></tr></g:each></tbody></table></div></section>
</g:if>
<g:else>
<section><h2>Completed job results</h2><div class="rw-table"><table><thead><tr><th>ID</th><th>Owner</th><th>Type</th><th>Completed</th><th>Description</th><th>Message</th><th>Result</th></tr></thead><tbody>
<g:each in="${jobs.findAll { it.status == 'COMPLETED' }}" var="j"><tr><td>${j.id}</td><td>${j.submittedBy?.encodeAsHTML()}</td><td>${j.jobType?.encodeAsHTML()}</td><td>${j.lastUpdated}</td><td>${descriptions[j.id]?.encodeAsHTML()}</td><td>${j.resultMessage?.encodeAsHTML()}</td><td><div class="rw-actions"><g:if test="${j.resultFileName}"><a class="rw-download" href="${request.contextPath}/remoteWork/download/${j.id}" title="Download ZIP" aria-label="Download ZIP for job ${j.id}"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M11 3h2v10.17l3.59-3.58L18 11l-6 6-6-6 1.41-1.41L11 13.17V3zM4 17h2v3h12v-3h2v5H4v-5z"/></svg></a></g:if><g:else>Not available</g:else>
<form class="rw-inline" action="${request.contextPath}/remoteWork/deleteResult/${j.id}" method="POST" onsubmit="return confirm('Delete result for job ${j.id}? This removes the job record from the list.');"><button type="submit" class="rw-danger" title="Delete result" aria-label="Delete result for job ${j.id}">✕</button></form></div></td></tr></g:each>
</tbody></table></div></section>
</g:else></div></main></div><g:render template="/shared/pmShellScript"/></div><script>
(function(){
 const zone=document.getElementById('rwDropzone');
 const input=document.getElementById('rwPackage');
 if(!zone||!input)return;
 const name=document.getElementById('rwFileName');
 const error=document.getElementById('rwFileError');
 const validate=function(){
   const file=input.files && input.files[0];
   name.textContent=file ? file.name+' ('+(file.size/1048576).toFixed(2)+' MB)' : 'No file selected';
   const valid=!file || /\.zip$/i.test(file.name);
   error.textContent=valid?'':'Only ZIP files can be uploaded.';
   input.setCustomValidity(valid?'':'Please select a ZIP file.');
   return valid;
 };
 zone.addEventListener('click',function(e){if(e.target!==input)input.click();});
 zone.addEventListener('keydown',function(e){if(e.key==='Enter'||e.key===' '){e.preventDefault();input.click();}});
 input.addEventListener('change',validate);
 ['dragenter','dragover'].forEach(function(type){zone.addEventListener(type,function(e){e.preventDefault();e.stopPropagation();zone.classList.add('rw-dragging');});});
 ['dragleave','drop'].forEach(function(type){zone.addEventListener(type,function(e){e.preventDefault();e.stopPropagation();zone.classList.remove('rw-dragging');});});
 zone.addEventListener('drop',function(e){
   const files=e.dataTransfer && e.dataTransfer.files;
   if(!files||!files.length)return;
   if(files.length!==1){error.textContent='Please drop one ZIP file at a time.';return;}
   try{input.files=files;}catch(ex){error.textContent='Your browser cannot accept this dropped file. Click to browse instead.';return;}
   validate();
 });
 const form=input.closest('form');
 if(form)form.addEventListener('submit',function(e){if(!validate()){e.preventDefault();input.reportValidity();}});
})();
async function loadScriptOptions(){
 const id=document.getElementById('scriptId').value;
 const target=document.getElementById('scriptOptions');target.replaceChildren();
 if(!id)return;
 try {
  const response=await fetch('${request.contextPath}/remoteWork/schema/'+encodeURIComponent(id));
  if(!response.ok)throw Error('Schema unavailable');
  const schema=await response.json();
  for(const field of (schema.fields||[])){
   const label=document.createElement('label');label.textContent=field.label+' ';
   let control;
   if(field.type==='select'){
    control=document.createElement('select');
    const empty=document.createElement('option');empty.value='';empty.textContent='Select…';control.append(empty);
    for(const value of field.options){const o=document.createElement('option');o.value=value;o.textContent=value;control.append(o)}
   }else{
    control=document.createElement('input');
    control.type=field.type==='integer'?'number':field.type==='boolean'?'checkbox':'text';
   }
   control.name='option_'+field.name;control.required=!!field.required && field.type!=='boolean';
   if(field.type==='boolean'){control.value='true';control.checked=field.default===true || field.default==='true';}else if(field.default!==undefined && field.default!==null){control.value=String(field.default);}
   label.append(control);target.append(label);
  }
 }catch(e){target.textContent=e.message;}
}
loadScriptOptions();
</script></body></html>

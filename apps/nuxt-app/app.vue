<template>
  <div>
    <h1>Nuxt crash-app</h1>
    <ul>
      <li><a href="/api/error">/api/error</a> — 500 через createError</li>
      <li><a href="/api/throw">/api/throw</a> — необработанное исключение</li>
      <li><a href="/api/rejection">/api/rejection</a> — необработанный promise rejection</li>
      <li><a href="/api/fatal">/api/fatal</a> — fatal, process.exit(1)</li>
      <li><a href="/api/error-502">/api/error-502</a> — 502 без краха</li>
    </ul>
  </div>
</template>

// Необработанный promise rejection: промис отклоняется, но его никто не ждёт
// и не перехватывает. Node логирует это как unhandledRejection.
export default defineEventHandler(() => {
  console.error('NUXT_REJECTION: unhandled promise rejection on /api/rejection')
  void Promise.reject(new Error('unhandled rejection in /api/rejection'))
  return { status: 'triggered' }
})

/*
 * File: condvar1.c
 *
 * Test Synopsis:
 * - Test PTHREAD_COND_INITIALIZER.
 *
 * Test Method (Validation or Falsification):
 * - Validation
 *
 * Requirements Tested:
 * - 
 *
 * Features Tested:
 * - 
 *
 * Cases Tested:
 * - 
 *
 * Description:
 * - Test basic CV function but starting with a static initialised
 *   CV.
 *
 * Environment:
 * - 
 *
 * Input:
 * - None.
 *
 * Output:
 * - File name, Line number, and failed expression on failure.
 * - No output on success.
 *
 * Assumptions:
 * - 
 *
 * Pass Criteria:
 * - pthread_cond_timedwait returns 0.
 * - Process returns zero exit status.
 *
 * Fail Criteria:
 * - pthread_cond_timedwait returns ETIMEDOUT.
 * - Process returns non-zero exit status.
 */

#include "test.h"

typedef struct cvthing_t_ cvthing_t;

struct cvthing_t_ {
  pthread_cond_t notbusy;
  pthread_mutex_t lock;
  int busy;
  int count;
};

static cvthing_t cvthing = {
  PTHREAD_MUTEX_INITIALIZER,
  PTHREAD_COND_INITIALIZER,
};

static enum {
  NUMTHREADS = 2
};

void *
mythread(void * arg)
{
  assert(pthread_mutex_lock(&cvthing.lock) == 0);

  assert(pthread_cond_signal(&cvthing.notbusy) == 0);

  assert(pthread_mutex_unlock(&cvthing.lock) == 0);

  return 0;
}

int
main()
{
  pthread_t t[NUMTHREADS];
  int result[NUMTHREADS];
  struct timespec abstime = { 0, 0 };
  struct timeval curtime;

  assert((t[0] = pthread_self()) != NULL);

  assert(pthread_mutex_lock(&cvthing.lock) == 0);

  gettimeofday(&curtime, NULL);
  abstime.tv_sec = curtime.tv_sec + 5; 

  assert(pthread_cond_timedwait(&cvthing.notbusy, &cvthing.lock, &abstime) == ETIMEDOUT);
  
  assert(pthread_create(&t[1], NULL, mythread, (void *) 1) == 0);

  gettimeofday(&curtime, NULL);
  abstime.tv_sec = curtime.tv_sec + 10;

  assert(pthread_cond_timedwait(&cvthing.notbusy, &cvthing.lock, &abstime) == 0);

  assert(pthread_mutex_unlock(&cvthing.lock) == 0);

  assert(pthread_cond_destroy(&cvthing) == 0);

  return 0;
}
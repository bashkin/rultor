/**
 * Copyright (c) 2009-2013, rultor.com
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met: 1) Redistributions of source code must retain the above
 * copyright notice, this list of conditions and the following
 * disclaimer. 2) Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided
 * with the distribution. 3) Neither the name of the rultor.com nor
 * the names of its contributors may be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
 * NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package com.rultor.stateful.s3;

import com.jcabi.aspects.Tv;
import com.jcabi.log.VerboseThreads;
import com.rultor.stateful.Lineup;
import java.security.SecureRandom;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
import org.junit.Assume;
import org.junit.Test;

/**
 * Integration case for {@link ObjectLineup}.
 * @author Yegor Bugayenko (yegor@tpc2.com)
 * @version $Id$
 */
public final class ObjectLineupITCase {

    /**
     * ObjectLineup can run code in parallel.
     * @throws Exception If some problem inside
     */
    @Test
    @org.junit.Ignore
    public void runsInParallel() throws Exception {
        final String key = System.getProperty("failsafe.s3.key");
        Assume.assumeNotNull(key);
        final Lineup lineup = new ObjectLineup(
            System.getProperty("failsafe.s3.bucket"),
            "S3LineupITCase.txt",
            key,
            System.getProperty("failsafe.s3.secret")
        );
        final int threads = 10;
        final CountDownLatch start = new CountDownLatch(1);
        final AtomicInteger count = new AtomicInteger();
        final ExecutorService svc =
            Executors.newFixedThreadPool(threads, new VerboseThreads());
        final Random rnd = new SecureRandom();
        final Callable<?> callable = new Callable<Integer>() {
            @Override
            public Integer call() throws Exception {
                start.await();
                return lineup.exec(
                    new Callable<Integer>() {
                        @Override
                        public Integer call() throws Exception {
                            final int num = count.get();
                            TimeUnit.MILLISECONDS.sleep(rnd.nextInt(Tv.TEN));
                            count.set(num + 1);
                            return count.get();
                        }
                    }
                );
            }
        };
        for (int thread = 0; thread < threads; ++thread) {
            svc.submit(callable);
        }
        start.countDown();
        svc.shutdown();
        MatcherAssert.assertThat(
            svc.awaitTermination(2, TimeUnit.MINUTES),
            Matchers.is(true)
        );
        MatcherAssert.assertThat(count.get(), Matchers.equalTo(threads));
    }

}

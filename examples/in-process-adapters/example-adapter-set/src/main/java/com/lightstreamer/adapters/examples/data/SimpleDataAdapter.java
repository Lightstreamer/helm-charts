
/*
 * Copyright (c) Lightstreamer Srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.lightstreamer.adapters.examples.data;

import java.io.File;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.lightstreamer.interfaces.data.DataProviderException;
import com.lightstreamer.interfaces.data.FailureException;
import com.lightstreamer.interfaces.data.ItemEventListener;
import com.lightstreamer.interfaces.data.SmartDataProvider;
import com.lightstreamer.interfaces.data.SubscriptionException;

public class SimpleDataAdapter implements SmartDataProvider {

    private static final Logger log = Logger.getLogger(SimpleDataAdapter.class.getName());

    private ItemEventListener listener;
    private volatile Greetings greetings;

    @SuppressWarnings("rawtypes")
    public void init(Map params, File configDir) throws DataProviderException {
    }

    public void setListener(ItemEventListener listener) {
        this.listener = listener;
    }

    public boolean isSnapshotAvailable(String itemName) throws SubscriptionException {
        return false;
    }

    public void subscribe(String itemName, Object itemHandle, boolean needsIterator)
            throws SubscriptionException, FailureException {
        if (itemName.equals("greetings")) {
            this.greetings = new Greetings(listener, itemHandle);
            CompletableFuture.runAsync(greetings)
                    .exceptionally(ex -> {
                        log.log(Level.SEVERE, "Unexpected error in Greetings task", ex);
                        return null;
                    });
        }
    }

    public void subscribe(String itemName, boolean needsIterator)
            throws SubscriptionException, FailureException {
    }

    public void unsubscribe(String itemName) throws SubscriptionException,
            FailureException {
        if (itemName.equals("greetings") && greetings != null) {
            this.greetings.stop();
        }
    }

    private static class Greetings implements Runnable {

        private final ItemEventListener listener;
        private final Object itemHandle;
        private volatile Thread runnerThread;
        private final Map<String, String> data = new HashMap<>();

        public Greetings(ItemEventListener listener, Object itemHandle) {
            this.listener = listener;
            this.itemHandle = itemHandle;
        }

        public void stop() {
            Thread t = runnerThread;
            if (t != null) {
                t.interrupt();
            }
        }

        public void run() {
            runnerThread = Thread.currentThread();
            int c = 0;

            while (!Thread.currentThread().isInterrupted()) {
                data.put("message", c % 2 == 0 ? "Hello" : "World");
                data.put("timestamp", Instant.now().toString());
                listener.smartUpdate(itemHandle, data, false);
                c++;
                try {
                    TimeUnit.MILLISECONDS.sleep(50);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }
    }

}
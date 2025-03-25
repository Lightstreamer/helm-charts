package com.lightstreamer.adapters.examples.first;

import java.io.File;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.lightstreamer.adapters.examples.first.commons.CommonUtils;
import com.lightstreamer.interfaces.data.DataProviderException;
import com.lightstreamer.interfaces.data.FailureException;
import com.lightstreamer.interfaces.data.ItemEventListener;
import com.lightstreamer.interfaces.data.SmartDataProvider;
import com.lightstreamer.interfaces.data.SubscriptionException;

public class SimpleDataAdapter implements SmartDataProvider {

    private ItemEventListener listener;
    private final Map<String, Object> subscribedItems;
    private volatile boolean initialized;

    public SimpleDataAdapter() {
        this.subscribedItems = new ConcurrentHashMap<>();
    }

    @Override
    public void setListener(ItemEventListener listener) {
        this.listener = listener;
    }

    @Override
    public void init(Map params, File configDir) throws DataProviderException {
        System.out.printf("Data Adapter using commons classes from %s%n", new CommonUtils());
        // System.out.printf("Data Adapter using MetadataAdapter classes from %s%n", new
        // MetadataAdapterUtils());

    }

    @Override
    public void unsubscribe(String itemName) throws SubscriptionException, FailureException {
    }

    @Override
    public boolean isSnapshotAvailable(String itemName) throws SubscriptionException {
        return false;
    }

    @Override
    public void subscribe(String itemName, Object itemHandle, boolean needsIterator)
            throws SubscriptionException, FailureException {
    }

    @Override
    public void subscribe(String itemName, boolean needsIterator) throws SubscriptionException, FailureException {
    }
}
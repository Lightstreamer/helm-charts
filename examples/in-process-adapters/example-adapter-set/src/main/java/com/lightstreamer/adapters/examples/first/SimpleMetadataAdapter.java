package com.lightstreamer.adapters.examples.first;

import java.io.File;
import java.util.Map;

import com.lightstreamer.adapters.examples.first.commons.CommonUtils;
import com.lightstreamer.adapters.metadata.LiteralBasedProvider;
import com.lightstreamer.interfaces.metadata.MetadataProviderException;

public class SimpleMetadataAdapter extends LiteralBasedProvider {
    
    public SimpleMetadataAdapter() {
        
    }

    @Override
    public void init(Map params, File dir) throws MetadataProviderException {
        System.out.printf("Metadata Data Adapter using commons classes from %s%n", new CommonUtils());
    }


}
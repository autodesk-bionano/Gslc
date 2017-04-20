FROM mono:4.8.0.495
ENV PATH="/gslc/bin:${PATH}"
ADD ./bin/* /gslc/bin/
ADD ./docs /gslc/docs
ADD ./gslc_lib /gslc/gslc_lib
ENTRYPOINT [ "mono", "/gslc/bin/Gslc.exe", "--lib", "/gslc/gslc_lib" ]

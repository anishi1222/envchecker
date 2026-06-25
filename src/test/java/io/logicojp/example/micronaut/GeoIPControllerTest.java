package io.logicojp.example.micronaut;

import io.micronaut.context.annotation.Replaces;
import io.micronaut.core.async.publisher.Publishers;
import io.micronaut.http.HttpRequest;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.test.extensions.junit5.annotation.MicronautTest;
import jakarta.inject.Inject;
import jakarta.inject.Singleton;
import org.junit.jupiter.api.Test;
import org.reactivestreams.Publisher;

import static org.junit.jupiter.api.Assertions.assertEquals;

@MicronautTest
class GeoIPControllerTest {

    private static final String GEO_IP_RESPONSE = """
            {"ip":"203.0.113.10","country":{"name":"Japan"}}
            """.trim();

    @Inject
    @Client("/")
    HttpClient client;

    @Test
    void callerEndpointReturnsGeoIpResponse() {
        String response = client.toBlocking().retrieve(HttpRequest.GET("/caller"));

        assertEquals(GEO_IP_RESPONSE, response);
    }

    @Singleton
    @Replaces(GeoIPClient.class)
    static class StubGeoIPClient implements GeoIPClient {
        @Override
        public Publisher<String> getMyIpText() {
            return Publishers.just(GEO_IP_RESPONSE);
        }
    }
}

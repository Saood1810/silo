package com.silo.repository;

import com.silo.entity.Quote;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface QuoteRepository extends JpaRepository<Quote, UUID> {

  @Query(value = "SELECT * FROM quotes ORDER BY random() LIMIT 1", nativeQuery = true)
  Optional<Quote> findRandom();

}

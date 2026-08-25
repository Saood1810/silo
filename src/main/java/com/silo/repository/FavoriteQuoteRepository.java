package com.silo.repository;

import com.silo.entity.FavoriteQuote;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FavoriteQuoteRepository extends JpaRepository<FavoriteQuote, UUID> {

  List<FavoriteQuote> findByUserId(UUID userId);

  Optional<FavoriteQuote> findByUserIdAndQuoteId(UUID userId, UUID quoteId);

  boolean existsByUserIdAndQuoteId(UUID userId, UUID quoteId);

  void deleteByUserIdAndQuoteId(UUID userId, UUID quoteId);

}

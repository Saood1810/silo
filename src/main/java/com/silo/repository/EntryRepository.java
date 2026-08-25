package com.silo.repository;

import com.silo.entity.Entry;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EntryRepository extends JpaRepository<Entry, UUID> {

  List<Entry> findByUserIdOrderByCreatedAtDesc(UUID userId);

  Optional<Entry> findByIdAndUserId(UUID id, UUID userId);

}

#pragma once

#include "duckdb/optimizer/predicate_transfer/hash_filter/hash_filter.hpp"
#include "duckdb/common/types/vector.hpp"

#ifdef UseHashFilter
namespace duckdb {
/**
 * Caller needs to check if table is empty and bloom filter is valid
 */
class HashFilterUseKernel {

public:
  // use hash filter (reuse column indices made by the caller)
  static void
  filter(vector<Vector> &input,
         shared_ptr<HashFilter> bloom_filter,
         SelectionVector &sel,
         idx_t &approved_tuple_count,
         idx_t row_num);
};
}
#endif
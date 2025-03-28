#pragma once

#include "duckdb/planner/logical_operator.hpp"
#include "duckdb/optimizer/predicate_transfer/bloom_filter/bloom_filter.hpp"
#include "duckdb/optimizer/predicate_transfer/hash_filter/hash_filter.hpp"

namespace duckdb {
class DAGEdge;

class DAGNode {
public:
    DAGNode(idx_t id, idx_t estimated_cardinality, bool root) : id(id), size(estimated_cardinality), root(root) {
    }

    idx_t Id() {
        return id;
    }

    void AddIn(idx_t from, Expression* filter,  bool forward);

#ifdef UseHashFilter
    void AddIn(idx_t from, shared_ptr<HashFilter> bloom_filter, bool forward);
#else
    void AddIn(idx_t from, shared_ptr<BlockedBloomFilter> bloom_filter, bool forward);
#endif

    void AddOut(idx_t to, Expression* filter, bool forward);

#ifdef UseHashFilter
    void AddOut(idx_t to, shared_ptr<HashFilter> bloom_filter, bool forward);
#else
    void AddOut(idx_t to, shared_ptr<BlockedBloomFilter> bloom_filter, bool forward);
#endif

    vector<unique_ptr<DAGEdge>> forward_in_;
    vector<unique_ptr<DAGEdge>> backward_in_;
    vector<unique_ptr<DAGEdge>> forward_out_;
    vector<unique_ptr<DAGEdge>> backward_out_;

    bool root;

    int priority = -1;

    idx_t size;

private:
    idx_t id;
};

class DAGEdge{
public:
    DAGEdge(idx_t id) : dest_(id) {
    }

    void Push(Expression* filter) {
        filters.emplace_back(filter);
    }

#ifdef UseHashFilter
    void Push(shared_ptr<HashFilter> bloom_filter) {
#else
    void Push(shared_ptr<BlockedBloomFilter> bloom_filter) {
#endif
        bloom_filters.emplace_back(bloom_filter);
    }
    
    idx_t GetDest() {
        return dest_;
    }

    vector<Expression*> filters;
    
#ifdef UseHashFilter
    vector<shared_ptr<HashFilter>> bloom_filters;
#else
    vector<shared_ptr<BlockedBloomFilter>> bloom_filters;
#endif

    idx_t dest_;
};

class DAG {
public:
    unordered_map<int, unique_ptr<DAGNode>> nodes;
};
}
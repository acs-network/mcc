#include "io_module.h"
#include "virtual_delay.h"

/*----------------------------------------------------------------------------*/
/**
 * init mbuf_list
 *
 * @param list 		target list
 *
 * @return null
 */
void
mbuf_list_init(mbuf_list_t list)
{
	list->head = NULL;
	list->tail = NULL;
}

/**
 * get the mbuf from the head of the list and remove it from the list
 *
 * @param list 		target list
 *
 * @return
 * 	return the mbuf_t if success, or return NULL if the list is empty
 */
mbuf_t
mbuf_list_pop(mbuf_list_t list)
{
	mbuf_t ret;
	ret = list->head;
	if (ret) {
		list->head = ret->buf_next;
		ret->buf_next = NULL;
		if (!list->head) {
			list->tail = NULL;
		}
	}
	return ret;
}

/**
 * add the mbuf to the tail of the list
 *
 * @param list 		target list
 * @param mbuf 		target mbuf
 *
 * @return null
 */
void
mbuf_list_append(mbuf_list_t list, mbuf_t mbuf)
{
	if (!list->tail) {
		list->head = mbuf;
		list->tail = mbuf;
		mbuf->buf_next = NULL;
	}
	else {
		list->tail->buf_next = mbuf;
		mbuf->buf_next = NULL;
		list->tail = mbuf;
	}
}
/*----------------------------------------------------------------------------*/
void
delay_list_append(mbuf_list_t list, mbuf_t mbuf, uint32_t ts)
{
	mbuf->delay_ts = ts;
	mbuf_list_append(list, mbuf);
}

mbuf_t
delay_list_timeout_lookup(mbuf_list_t list, uint32_t cur_ts, uint32_t timeout)
{
	if (!list->head) {
		return NULL;
	}
	if (cur_ts - list->head->delay_ts >= timeout) {
		return mbuf_list_pop(list);
	} else {
		return NULL;
	}
}
/*----------------------------------------------------------------------------*/
void
delay_list_append_batch(mbuf_list_t list, mbuf_t *pkts, int cnt, uint32_t ts, 
		struct rte_mempool *pool) 
{
	int i;
	for (i = 0; i < cnt; i++) {
		delay_list_append(list, pkts[i], ts);
		pkts[i] = rte_pktmbuf_alloc(pool);
		if (unlikely(pkts[i] == NULL)) {
			fprintf(stderr, "failed to allocate mbuf from %p!"
					" list len:%d cur_burst:%d enqueued:%d, alloc_cnt %ld, send_cnt %ld"
          ", mempool_avail_count : %d\n", 
					pool, list->cnt, cnt, i, alloc_cnt, send_cnt, rte_mempool_avail_count(pool));
            exit(EXIT_FAILURE);
		}
    alloc_cnt++;
	}
	list->cnt += cnt;
}

int
delay_list_check(mbuf_list_t list, mbuf_t *pkts, int max_cnt, uint32_t cur_ts, 
		uint32_t timeout)
{
	mbuf_t ret = delay_list_timeout_lookup(list, cur_ts, timeout);
	int cnt = 0;
	while (cnt < max_cnt && ret) {
		pkts[cnt] = ret;
		cnt++;
//		fprintf(stdout, "pkt_ts: %u, cur_ts:%u\n", ret->delay_ts, cur_ts);
		ret = delay_list_timeout_lookup(list, cur_ts, timeout);
	}
	list->cnt -= cnt;
	return cnt;
}
/*----------------------------------------------------------------------------*/

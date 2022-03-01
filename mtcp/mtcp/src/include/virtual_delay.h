#include <rte_mbuf.h>
#include "io_module.h"

typedef struct rte_mbuf *mbuf_t;
struct mbuf_list
{
	mbuf_t head;
	mbuf_t tail;
	int cnt;
};
typedef struct mbuf_list *mbuf_list_t;

/*----------------------------------------------------------------------------*/
/**
 * init mbuf_list
 *
 * @param list 		target list
 *
 * @return null
 */
void
mbuf_list_init(mbuf_list_t list);

/**
 * get the mbuf from the head of the list and remove it from the list
 *
 * @param list 		target list
 *
 * @return
 * 	return the mbuf_t if success, or return NULL if the list is empty
 */
mbuf_t
mbuf_list_pop(mbuf_list_t list);

/**
 * add the mbuf to the tail of the list
 *
 * @param list 		target list
 * @param mbuf 		target mbuf
 *
 * @return null
 */
void
mbuf_list_append(mbuf_list_t list, mbuf_t mbuf);
/*----------------------------------------------------------------------------*/
void
delay_list_append(mbuf_list_t list, mbuf_t mbuf, uint32_t ts);

mbuf_t
delay_list_timeout_lookup(mbuf_list_t list, uint32_t cur_ts, uint32_t timeout);

/*----------------------------------------------------------------------------*/
void
delay_list_append_batch(mbuf_list_t list, mbuf_t *pkts, int cnt, uint32_t ts, 
		struct rte_mempool *pool); 

int
delay_list_check(mbuf_list_t list, mbuf_t *pkts, int max_cnt, uint32_t cur_ts, 
		uint32_t timeout);

/*----------------------------------------------------------------------------*/

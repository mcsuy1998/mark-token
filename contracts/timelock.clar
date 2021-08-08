;; There are roughly 52560 blocks per year. (One every 10 minutes.)

(define-constant unlock-height (+ block-height u52560))
(define-constant beneficiary 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE )

(define-read-only (get-unlock-height)
	unlock-height
)

(define-public (redeem (recipient principal))
	(begin
		(asserts! (is-eq tx-sender beneficiary) (err u100)) ;; not the beneficiary
		(asserts! (>= block-height unlock-height) (err u101)) ;; block-height not reached
		(as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender recipient))
	)
)
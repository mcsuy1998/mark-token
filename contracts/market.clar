
(use-trait nft-trait .sip009-nft-trait.nft-trait)

(define-map listings
	;; key
	{id: uint}
	;; values
	{
		maker: principal,
		nft-contract: principal,
		token-id: uint,
		price: uint
	}
)

(define-constant err-unknown-listing (err u100))
(define-constant err-not-the-maker (err u101))
(define-constant err-wrong-trait-reference (err u102))

(define-data-var listing-nonce uint u0)

(define-public (list-nft (nft-contract <nft-trait>) (token-id uint) (price uint))
	(begin
		(try! (contract-call? nft-contract transfer token-id tx-sender (as-contract tx-sender)))
		(map-set listings
			{id: (+ (var-get listing-nonce) u1)}
			{maker: tx-sender, nft-contract: (contract-of nft-contract), token-id: token-id, price: price}
		)
		(ok true)
	)
)

(define-read-only (get-listing (listing-id uint))
	(map-get? listings {id: listing-id})
)

(define-public (cancel-listing (nft-contract <nft-trait>) (listing-id uint))
	(let
		(
			(listing (unwrap! (get-listing listing-id) err-unknown-listing))
			(maker (get maker listing))
			(token-id (get token-id listing))
		)
		(asserts! (is-eq tx-sender maker) err-not-the-maker)
        (asserts! (is-eq (contract-of nft-contract) (get nft-contract listing)) err-wrong-trait-reference)
		(try! (as-contract (contract-call? nft-contract transfer token-id tx-sender maker)))
		(map-delete listings {id: listing-id})
		(ok true)
	)
)

;; we want to make a stacks transfer 

(define-public (fulfill-listing (nft-contract <nft-trait>) (listing-id uint)) 
    (let
		(
			(listing (unwrap! (get-listing listing-id) err-unknown-listing))
			(maker (get maker listing))
            (price (get price listing))
			(token-id (get token-id listing))
            (taker tx-sender)
		)
        (try! (stx-transfer? price taker maker))
        (try! (as-contract (contract-call? nft-contract transfer token-id tx-sender taker) ))
        (asserts! (is-eq (contract-of nft-contract) (get nft-contract listing)) err-wrong-trait-reference)
        (map-delete listings {id: listing-id})
        (ok true)
    )
)

;; mark-token

(impl-trait .sip009-nft-trait.nft-trait)

(define-non-fungible-token mark-token uint)

(define-data-var last-token-id uint u0) 


(define-public (mint)
    (begin 
        (var-set last-token-id (+ (var-get last-token-id ) u1))
        (nft-mint? mark-token (var-get last-token-id) tx-sender)    
    )
)

(define-public (get-last-token-id) 
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok none)
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? mark-token token-id))
)


(define-public (transfer (token-id uint) (sender principal) (recipient principal))
	(nft-transfer? mark-token token-id sender recipient)
)

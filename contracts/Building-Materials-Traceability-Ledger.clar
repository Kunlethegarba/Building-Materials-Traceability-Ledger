(define-non-fungible-token material-batch uint)

(define-constant contract-owner tx-sender)

(define-map material-records
    uint 
    {
        material-type: (string-ascii 64),
        manufacturer: principal,
        batch-number: (string-ascii 32),
        production-date: uint,
        certification-status: bool,
        certifier: principal,
        quality-score: uint,
        location: (string-ascii 64)
    }
)

(define-map manufacturer-registry
    principal 
    {
        name: (string-ascii 64),
        license-number: (string-ascii 32),
        verified: bool
    }
)

(define-map certifier-registry
    principal
    {
        name: (string-ascii 64),
        certification-authority: (string-ascii 32),
        active: bool
    }
)

(define-data-var last-token-id uint u0)

(define-map transfer-requests
    uint
    {
        from: principal,
        to: principal,
        timestamp: uint,
        pending: bool
    }
)

(define-public (register-manufacturer (name (string-ascii 64)) (license-number (string-ascii 32)))
    (let
        (
            (manufacturer tx-sender)
        )
        (ok (map-set manufacturer-registry manufacturer {
            name: name,
            license-number: license-number,
            verified: false
        }))
    )
)

(define-public (verify-manufacturer (manufacturer principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err u403))
        (ok (map-set manufacturer-registry manufacturer 
            (merge (unwrap-panic (map-get? manufacturer-registry manufacturer))
                {verified: true})))
    )
)

(define-public (register-certifier (name (string-ascii 64)) (certification-authority (string-ascii 32)))
    (let
        (
            (certifier tx-sender)
        )
        (ok (map-set certifier-registry certifier {
            name: name,
            certification-authority: certification-authority,
            active: false
        }))
    )
)

(define-public (activate-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err u403))
        (ok (map-set certifier-registry certifier 
            (merge (unwrap-panic (map-get? certifier-registry certifier))
                {active: true})))
    )
)

(define-public (register-material-batch 
        (material-type (string-ascii 64))
        (batch-number (string-ascii 32))
        (production-date uint)
        (location (string-ascii 64)))
    (let
        (
            (manufacturer tx-sender)
            (token-id (+ (var-get last-token-id) u1))
            (manufacturer-data (unwrap! (map-get? manufacturer-registry manufacturer) (err u404)))
        )
        (asserts! (get verified manufacturer-data) (err u401))
        (try! (nft-mint? material-batch token-id manufacturer))
        (var-set last-token-id token-id)
        (ok (map-set material-records token-id {
            material-type: material-type,
            manufacturer: manufacturer,
            batch-number: batch-number,
            production-date: production-date,
            certification-status: false,
            certifier: contract-owner,
            quality-score: u0,
            location: location
        }))
    )
)

(define-public (certify-batch 
        (token-id uint)
        (quality-score uint))
    (let
        (
            (certifier tx-sender)
            (certifier-data (unwrap! (map-get? certifier-registry certifier) (err u404)))
            (batch-data (unwrap! (map-get? material-records token-id) (err u404)))
        )
        (asserts! (get active certifier-data) (err u401))
        (ok (map-set material-records token-id 
            (merge batch-data {
                certification-status: true,
                certifier: certifier,
                quality-score: quality-score
            })))
    )
)

(define-read-only (get-batch-details (token-id uint))
    (ok (unwrap! (map-get? material-records token-id) (err u404)))
)

(define-read-only (get-manufacturer-details (manufacturer principal))
    (ok (unwrap! (map-get? manufacturer-registry manufacturer) (err u404)))
)

(define-read-only (get-certifier-details (certifier principal))
    (ok (unwrap! (map-get? certifier-registry certifier) (err u404)))
)

(define-public (initiate-transfer (token-id uint) (recipient principal))
    (let
        (
            (current-owner (unwrap! (nft-get-owner? material-batch token-id) (err u404)))
            (current-block stacks-block-height)
        )
        (asserts! (is-eq tx-sender current-owner) (err u403))
        (ok (map-set transfer-requests token-id {
            from: current-owner,
            to: recipient,
            timestamp: current-block,
            pending: true
        }))
    )
)

(define-public (accept-transfer (token-id uint))
    (let
        (
            (transfer-data (unwrap! (map-get? transfer-requests token-id) (err u404)))
            (recipient (get to transfer-data))
            (sender (get from transfer-data))
        )
        (asserts! (is-eq tx-sender recipient) (err u403))
        (asserts! (get pending transfer-data) (err u400))
        (try! (nft-transfer? material-batch token-id sender recipient))
        (ok (map-set transfer-requests token-id 
            (merge transfer-data {pending: false})))
    )
)

(define-public (cancel-transfer (token-id uint))
    (let
        (
            (transfer-data (unwrap! (map-get? transfer-requests token-id) (err u404)))
            (sender (get from transfer-data))
        )
        (asserts! (is-eq tx-sender sender) (err u403))
        (asserts! (get pending transfer-data) (err u400))
        (ok (map-delete transfer-requests token-id))
    )
)

(define-read-only (get-transfer-status (token-id uint))
    (ok (map-get? transfer-requests token-id))
)

(define-map batch-recalls uint bool)

(define-public (recall-batch (token-id uint))
    (let
        (
            (batch-data (unwrap! (map-get? material-records token-id) (err u404)))
            (manufacturer (get manufacturer batch-data))
        )
        (asserts! (is-eq tx-sender manufacturer) (err u403))
        (ok (map-set batch-recalls token-id true))
    )
)

(define-read-only (is-batch-recalled (token-id uint))
    (default-to false (map-get? batch-recalls token-id))
)
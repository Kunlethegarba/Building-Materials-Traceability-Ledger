# 🏗️ Building Materials Traceability Ledger

A Stacks blockchain solution for ensuring transparency and traceability in construction material supply chains.

## 🎯 Purpose

This smart contract creates an immutable record-keeping system for construction materials, helping prevent the infiltration of substandard materials by maintaining a transparent chain of custody and certification.

## ✨ Features

- 📦 Register material batches as NFTs
- 🏢 Manufacturer registration and verification
- 🔍 Certifier registration and activation
- ✅ Material batch certification
- 📊 Quality scoring system
- 🔎 Transparent batch history tracking

## 🚀 Getting Started

### Prerequisites
- Clarinet
- Stacks wallet

### Contract Functions

1. **Manufacturer Operations**
   ```clarity
   (register-manufacturer name license-number)
   ```

2. **Certifier Operations**
   ```clarity
   (register-certifier name certification-authority)
   ```

3. **Material Batch Operations**
   ```clarity
   (register-material-batch material-type batch-number production-date location)
   (certify-batch token-id quality-score)
   ```

4. **Query Functions**
   ```clarity
   (get-batch-details token-id)
   (get-manufacturer-details manufacturer)
   (get-certifier-details certifier)
   ```

## 🔒 Security

- Only verified manufacturers can register material batches
- Only active certifiers can certify batches
- Contract owner controls manufacturer verification and certifier activation

## 📝 License

MIT
```

Git commit message:
```
feat: implement Building Materials Traceability Ledger smart contract MVP
```

PR Title:
```
✨ Add Building Materials Traceability Smart Contract
```

PR Description:
```
This PR introduces the Building Materials Traceability Ledger smart contract with the following features:

- NFT-based material batch tracking
- Manufacturer registration and verification system
- Certifier management
- Batch certification with quality scoring
- Comprehensive query functions

The implementation provides a minimal yet complete solution for tracking construction materials on the Stacks blockchain.

Testing completed:
- ✅ Contract deployment
- ✅ Basic functionality tests
- ✅ Access control verification


import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import './TokenFaucetDApp.css';

const TokenFaucetDApp = () => {
  const [account, setAccount] = useState(null);
  const [balance, setBalance] = useState('0');
  const [isClaiming, setIsClaiming] = useState(false);
  const [message, setMessage] = useState('');
  const [remainingCooldown, setRemainingCooldown] = useState(0);
  const [faucetAmount, setFaucetAmount] = useState('0');
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [faucetContract, setFaucetContract] = useState(null);
  const [tokenContract, setTokenContract] = useState(null);

  const FAUCET_ADDRESS = process.env.REACT_APP_FAUCET_ADDRESS || '';
  const TOKEN_ADDRESS = process.env.REACT_APP_TOKEN_ADDRESS || '';
  const NETWORK = process.env.REACT_APP_NETWORK || 'sepolia';

  // ABI for Token and Faucet contracts
  const TOKEN_ABI = [
    'function balanceOf(address owner) view returns (uint256)',
    'function approve(address spender, uint256 amount) returns (bool)',
    'function transfer(address to, uint256 amount) returns (bool)'
  ];

  const FAUCET_ABI = [
    'function claimTokens() public',
    'function canClaim(address user) public view returns (bool)',
    'function getRemainingCooldown(address user) public view returns (uint256)',
    'function faucetAmount() public view returns (uint256)',
    'event TokensClaimed(address indexed user, uint256 amount)'
  ];

  useEffect(() => {
    initializeWallet();
  }, []);

  useEffect(() => {
    if (signer && faucetContract && tokenContract) {
      loadUserData();
      const interval = setInterval(loadUserData, 2000);
      return () => clearInterval(interval);
    }
  }, [signer, faucetContract, tokenContract]);

  const initializeWallet = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const prov = new ethers.BrowserProvider(window.ethereum);
        setProvider(prov);

        // Request account access
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        if (accounts.length > 0) {
          setAccount(accounts[0]);
          const sig = await prov.getSigner();
          setSigner(sig);

          // Initialize contracts
          const faucet = new ethers.Contract(FAUCET_ADDRESS, FAUCET_ABI, sig);
          const token = new ethers.Contract(TOKEN_ADDRESS, TOKEN_ABI, sig);
          setFaucetContract(faucet);
          setTokenContract(token);
        }
      } catch (error) {
        setMessage('Error initializing wallet: ' + error.message);
      }
    } else {
      setMessage('Please install MetaMask!');
    }
  };

  const loadUserData = async () => {
    try {
      if (!tokenContract || !faucetContract || !account) return;

      const bal = await tokenContract.balanceOf(account);
      setBalance(ethers.formatEther(bal));

      const amount = await faucetContract.faucetAmount();
      setFaucetAmount(ethers.formatEther(amount));

      const cooldown = await faucetContract.getRemainingCooldown(account);
      setRemainingCooldown(Number(cooldown));
    } catch (error) {
      console.error('Error loading user data:', error);
    }
  };

  const handleClaimTokens = async () => {
    if (!faucetContract) {
      setMessage('Faucet contract not initialized');
      return;
    }

    try {
      setIsClaiming(true);
      setMessage('Claiming tokens...');

      const canClaim = await faucetContract.canClaim(account);
      if (!canClaim) {
        setMessage(`Cannot claim yet. Remaining cooldown: ${remainingCooldown}s`);
        return;
      }

      const tx = await faucetContract.claimTokens();
      const receipt = await tx.wait();

      if (receipt.status === 1) {
        setMessage(`Successfully claimed ${faucetAmount} tokens!`);
        await loadUserData();
      } else {
        setMessage('Transaction failed');
      }
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    } finally {
      setIsClaiming(false);
    }
  };

  const formatAddress = (addr) => {
    if (!addr) return '';
    return addr.substring(0, 6) + '...' + addr.substring(addr.length - 4);
  };

  return (
    <div className="token-faucet-container">
      <div className="faucet-card">
        <h1>Token Faucet DApp</h1>
        <div className="account-section">
          <p>Connected Account: {account ? formatAddress(account) : 'Not connected'}</p>
          <p>Balance: {balance} tokens</p>
        </div>
        <div className="faucet-section">
          <p>Faucet Amount: {faucetAmount} tokens per claim</p>
          <p>Remaining Cooldown: {remainingCooldown} seconds</p>
          <button 
            onClick={handleClaimTokens}
            disabled={isClaiming || remainingCooldown > 0}
            className="claim-button"
          >
            {isClaiming ? 'Claiming...' : remainingCooldown > 0 ? `Wait ${remainingCooldown}s` : 'Claim Tokens'}
          </button>
        </div>
        {message && <div className="message">{message}</div>}
      </div>
    </div>
  );
};

export default TokenFaucetDApp;

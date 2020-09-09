import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import CircularProgress from '@material-ui/core/CircularProgress';
import Multiselect from './inputs/Multiselect';
import DateInput from './inputs/Date';
import Fields from './inputs/Fields';
import RangeSlider from './inputs/RangeSlider';
import {
  fields, vCountries, vLanguages, vCategories, vSources, vDuplicate
} from './options.js';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1
  },
  inputRow: {
    width: 500,
    display: 'flex',
    justifyContent: 'space-between'
  },
  inputFieldsRow: {
    width: 500,
    display: 'flex',
    marginTop: 25,
    marginBottom: 5
  },
  title: {
    flexGrow: 1,
    textAlign: 'left'
  },
  content: {
    display: 'flex',
    flexDirection: 'column',
    flexWrap: 'wrap',
    flex: 'auto',
    padding: 30,
    '& > * + *': {
      marginTop: theme.spacing(1),
    },
    position: 'absolute',
    top: 60,
    bottom: 60,
    left: 0,
    right: 0,
    overflowY: 'auto'
  },
  footer: {
    height: 55,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    background: '#eee',
    lineHeight: '52px'
  },
  progress: {
    position: 'fixed',
    bottom: 12,
    left: 12
  },
  ndocs: {
    position: 'fixed',
    left: 18,
    bottom: 18
  }
}));

export default function Container() {
  const classes = useStyles();

  const [stFields, setStFields] = useState(fields);
  const updateFields = (val) => {
    const newState = [...stFields];
    const idx = stFields.indexOf(val);
    if (idx < 0) {
      newState.push(val);
    } else {
      newState.splice(idx, 1);
    }
    setStFields(newState);
  }

  const [nDocs, setNDocs] = useState(null)
  const [nDocsLoading, setNDocsLoading] = useState(false)
  const [nDocsLoaded, setNDocsLoaded] = useState(false)
  const [hasError, setHasError] = useState(false)

  const [stCategory, setStCategory] = useState([]);          // mselect
  const [stCountry, setStCountry] = useState([]);            // mselect
  const [stLanguage, setStLanguage] = useState([]);          // mselect
  const [stSource, setStSource] = useState([]);              // mselect
  const [stDuplicate, setStDuplicate] = useState([]);        // mselect
  const [stIndexdate1, setStIndexdate1] = useState(null);    // date
  const [stIndexdate2, setStIndexdate2] = useState(null);    // date
  const [stPubdate1, setStPubdate1] = useState(null);        // date
  const [stPubdate2, setStPubdate2] = useState(null);        // date
  const [stText, setStText] = useState('');                  // text input
  const [stTonality, setStTonality] = useState([-100, 100]); // slider
  const [stEntityid, setStEntityid] = useState('');          // text input
  const [stGeorssid, setStGeorssid] = useState('');          // text input
  const [stGuid, setStGuid] = useState('');                  // text input

  useEffect(() => {
    const res = {
      stCategory,
      stCountry,
      stLanguage,
      stSource,
      stDuplicate,
      stIndexdate1,
      stIndexdate2,
      stPubdate1,
      stPubdate2,
      stText,
      stTonality,
      stEntityid,
      stGeorssid,
      stGuid
    };
    const jj = (x) => x.join(',');
    const url = `http://localhost:8000/get_ndocs?category=${jj(stCategory)}&country=${jj(stCountry)}&language=${jj(stLanguage)}&source=${jj(stSource)}&duplicate=${jj(stDuplicate)}&pubdate=${stPubdate1},${stPubdate2}&indexdate=${stIndexdate1},${stIndexdate2}&text=${stText}&tonality=${jj(stTonality)}&entityid=${stEntityid}&georssid=${stGeorssid}&guid=${stGuid}`;
    console.log(url);

    setNDocsLoading(true)
    fetch(url)
      .then(response => response.json())
      .then(data => {
        setNDocs(data);
        setNDocsLoading(false);
        setNDocsLoaded(true);
        console.log(data);
      })
      .catch(() => {
        setHasError(true)
        setNDocsLoading(false)
      });
  }, [stCategory,
    stCountry,
    stLanguage,
    stSource,
    stDuplicate,
    stIndexdate1,
    stIndexdate2,
    stPubdate1,
    stPubdate2,
    stText,
    stTonality,
    stEntityid,
    stGeorssid,
    stGuid]);

  return (
    <div className={classes.root}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" className={classes.title}>
            Finder Query Builder
          </Typography>
        </Toolbar>
      </AppBar>
      <div className={classes.content}>
        <Multiselect label="Category" values={vCategories} setter={setStCategory} />
        <Multiselect label="Country" values={vCountries} setter={setStCountry} />
        <Multiselect label="Language" values={vLanguages} setter={setStLanguage} />
        <Multiselect label="Source" values={vSources} setter={setStSource} />
        <Multiselect label="Duplicate" values={vDuplicate} setter={setStDuplicate} />
        <div className={classes.inputRow}>
          <DateInput label="pubDate start" setter={setStPubdate1} />
          <DateInput label="pubDate end"  setter={setStPubdate2} />
        </div>
        <div className={classes.inputRow}>
          <DateInput label="indexDate start" setter={setStIndexdate1} />
          <DateInput label="indexDate end" setter={setStIndexdate2} />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="Text (search in title, description, body text)"
            value={stText}
            onChange={(event) => setStText(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <RangeSlider value={stTonality} setter={setStTonality} />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="entityid"
            value={stEntityid}
            onChange={(event) => setStEntityid(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="georssid"
            value={stGeorssid}
            onChange={(event) => setStGeorssid(event.target.value)}
          />
        </div>
        <div className={classes.inputRow}>
          <TextField
            fullWidth
            label="guid"
            value={stGuid}
            onChange={(event) => setStGuid(event.target.value)}
          />
        </div>
        <div>
          <div className={classes.inputFieldsRow}>
            Document fields to return:
          </div>
          <div className={classes.inputRow}>
            <Fields update={updateFields} selectedFields={stFields} />
          </div>
        </div>
      </div>
      <div className={classes.footer}>
        <Button variant="contained" color="primary">
          Run Query
        </Button>
      </div>
      {nDocsLoading && (<CircularProgress className={classes.progress} size={30} />)}
      {nDocsLoaded && (<div className={classes.ndocs}>{`${nDocs} documents`}</div>)}
    </div>
  );
}
<!-- The EHR API documentation can be found at:
https://specifications.openehr.org/releases/ITS-REST/Release-1.0.3/ehr.html#tag/COMPOSITION
 -->

<script setup>
import { ref, onMounted, nextTick, computed, watch } from 'vue';
import webTemplate from '@/assets/templates/task1_vital_signs_fabianb.v0.json';
import { useToast } from "primevue/usetoast";
import Select from 'primevue/select';
const toast = useToast();

const showToast = (severity, summary, detail, life = 3000) => {
    console.log("toast loading")
    toast.add({ severity, summary, detail, life});
};

const loadedCompositions = ref([]);
const selectedComposition = ref(null);
const loading = ref(false);
const error = ref(null);

// For the dropdown menu
const selectedTemplate = ref("all"); // default to 'all' if none selected
// computed
const templates = computed(() => {
  if (!loadedCompositions.value || !Array.isArray(loadedCompositions.value)) {
    return []; // keep dropdown empty without error while loading
  }
  // create a set to show unique templates only
  const uniqueTemplates = new Set(
    loadedCompositions.value
      .filter(composition => composition?.template) // ensure composition and template exist
      .map(composition => composition.template)
  );

    return [
    { name: "All", value: "all" }, // add "All" option at the beginning of the array
    ...Array.from(uniqueTemplates).map(template => ({
    name: template, // every item in the dropdown menu has a name and a value.
    value: template
}))]});

// Filters the locally stored compositions based on a dropdown menu
const filteredCompositions = computed(() => {
    console.log("Selected Template changed: ", selectedTemplate.value)
if (!selectedTemplate.value || selectedTemplate.value === "all") {
return loadedCompositions.value; // Show all compositions if no template or "All" is selected
}
return loadedCompositions.value.filter(composition => composition.template === selectedTemplate.value);
});

const form = ref(null);

// const BASE_URL = 'https://openehr-bootcamp.medblocks.com/ehrbase' // use this as proxy in vite.config to avoid CORS problems 
// const OPENEHR_BASE_URL = `${BASE_URL}/rest/openehr/v1`  
const OPENEHR_BASE_URL = '/api/ehrbase/rest/openehr/v1' // use this to avoid CORS problem in development

const ehrId = '6adc37f8-fff8-4fe4-a988-327b9fe6d5ac'
let templateId = null 

// Fetches all Compositions in the patients EHR and stores them as 'loadedCompositions', which then can be filtered
async function loadCompositions() {
            try {
        const response = await fetch(`${OPENEHR_BASE_URL}/query/aql`, {
            method: 'POST',
            body: JSON.stringify({
              "q": `SELECT e/ehr_id/value,
              c/archetype_details/template_id/value,
              c/uid/value, c/context/start_time/value
              FROM EHR e[ehr_id/value = '${ehrId}']
              CONTAINS COMPOSITION c`
          }), // always stringify the body!
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            }
        });

        if (!response.ok) {
          const errorMessage = await response.text(); // get exact server response
          throw new Error(`HTTP error! Status: ${response.status}, Message: ${errorMessage}`);
      }
        const responseData = await response.json();
        //loadedCompositions.value = responseData
        console.log("Loaded Compositions:", responseData);
        const rows = responseData.rows
        loadedCompositions.value = rows
            // maps the values in the order that they appear in the "rows"-array. This is defined be the order of the aql query.
            .map(([ehrid,template,uid,timestamp]) => ({ehrid,template,uid,timestamp}))
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)); // Sort by date (descending)
        console.log("Compositions: " + loadedCompositions.value);
  }
  catch (error) {
        console.error('Error querying the compositions:', error);
    }
}

/*
async function queryCompositionsByTemplate() {
            try {
        const response = await fetch(`${OPENEHR_BASE_URL}/query/aql`, {
            method: 'POST',
            body: JSON.stringify({
              "q": `SELECT e/ehr_id/value,
                    c/archetype_details/template_id/value,
                    c/uid/value, c/context/start_time/value
                    FROM EHR e[ehr_id/value = '${ehrId}']
                    CONTAINS COMPOSITION c[archetype_details/template_id/value = '${selectedTemplate.value}']`
          }), // always stringify the body!
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            }
        });

        if (!response.ok) {
          const errorMessage = await response.text(); // get exact server response
          throw new Error(`HTTP error! Status: ${response.status}, Message: ${errorMessage}`);
      }
        const responseData = await response.json();
        //loadedCompositions.value = responseData
        console.log("Selected Compositions:", responseData);
        const rows = responseData.rows
        filterdCompositions.value = rows
            // maps the values in the order that they appear in the "rows"-array. This is defined be the order of the aql query.
            .map(([ehrid,template,uid,timestamp]) => ({ehrid,template,uid,timestamp}))
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp)); // Sort by date (descending)
        console.log("Selected Compositions: " + filterdCompositions.value);
        
  }
  catch (error) {
        console.error('Error querying the compositions:', error);
    }
}*/

/* When clicking on the delete button, found on the composition card,
a DELETE request will be sent to the ehrBase server, to delete this version of the composition.
This won't hard-delete the composition, but it won't appear in regular queries anymore.
Hard-deletion is not possible via the REST API */

/*
async function deleteComposition(uid) {
    if (!uid) {
        console.error("Invalid UID for deletion");
    return;
  }

  console.log("Deleting composition with UID:", uid);
  try {
        const response = await fetch(`${OPENEHR_BASE_URL}/ehr/${ehrId}/composition/${uid}`, {
            method: 'DELETE',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json', // form.value.export() returns flat json
                'Prefer': "return=presentation"
            }
        });
        console.log("Composition deleted successfully");
        showToast('secondary','Deleted', 'Composition successfully deleted');
        await listCompositions();
  }
  catch (error) {
        console.error('Error deleting the composition:', error);
    }
}
*/


const compositionText = ref(null); // Stores the text representation of the composition

async function showCompositionAsText(uid) {
    if (!uid) {
        console.error("Invalid UID for loading composition");
        return;
    }
    console.log("Loading composition with UID:", uid);

    try {
        const response = await fetch(`${OPENEHR_BASE_URL}/ehr/${ehrId}/composition/${uid}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/openehr.wt.flat.schema+json', /* Medblocks UI always expects FLAT JSON */
                'Content-Type': 'application/json',
            }
        });

        if (!response.ok) {
            const errorMessage = await response.text();
            throw new Error(`HTTP error! Status: ${response.status}, Message: ${errorMessage}`);
        }
        
        // Save the selected Composition and convert it to readable text
        selectedComposition.value = await response.json();
        console.log("API Response:", selectedComposition.value);
        compositionText.value = formatCompositionText(selectedComposition.value);
        showToast('info', 'Composition Loaded', 'Now displaying the selected composition.');

    } catch (error) {
        console.error('Error loading the composition:', error);
        showToast('error', 'Error', 'Failed to load composition.');
    }
}

// Helper function to format composition content into plain text
function formatCompositionText(composition) {
    if (!composition || typeof composition !== 'object') {
        return "No data available.";
    }
    return Object.entries(composition)
        .map(([key, value]) => `${key}: ${typeof value === 'object' ? JSON.stringify(value, null, 2) : value}`)
        .join("\n");
}

// Query by element (https://docs.ehrbase.org/docs/EHRbase/Explore/AQL/Contains)
// 
async function fetchVitals() {
  try {
      // Construct AQL query based on selected template so either values of 'All' or a specific template are displayed
      let query = `
      SELECT c/context/start_time/value, f/name/value, f/value/magnitude, c/archetype_details/template_id/value 
      FROM EHR e[ehr_id/value = '${ehrId}'] 
      CONTAINS COMPOSITION c CONTAINS ELEMENT f 
      WHERE (f/name/value = 'Diastolic' OR f/name/value = 'Systolic' OR f/name/value = 'Pulse rate')`;

    // add condition to the query depending on the selected template
    if (selectedTemplate.value !== "all") {
      query += ` AND c/archetype_details/template_id/value = '${selectedTemplate.value}'`;
    }

    // send AQL POST request
    const response = await fetch(`${OPENEHR_BASE_URL}/query/aql`, {
      method: 'POST',
      body: JSON.stringify({
        q: `${query}`
      }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    });

        if (!response.ok) {
          const errorMessage = await response.text(); // get exact server response
          throw new Error(`HTTP error! Status: ${response.status}, Message: ${errorMessage}`);
      }
        const responseData = await response.json();
        console.log("Fetched Vitals Data (Before Processing):", responseData.rows);

        // Convert data into a structured format
        const vitalsMap = new Map();

        responseData.rows.forEach(([timestamp, element, value, template]) => {
          const date = new Date(timestamp).toISOString(); // Normalize timestamps

          if (!vitalsMap.has(date)) {
        vitalsMap.set(date, { 
          timestamp: date, 
          Systolic: { value: null, template: null }, 
          Diastolic: { value: null, template: null }, 
          "Pulse rate": { value: null, template: null } 
        });
      }

      vitalsMap.get(date)[element] = { value, template }; // Store value and its associated template
    });

        // Convert Map to array and sort chronologically; Sorting could also be done in the AQL query with GROUP BY c/context/start_time/value DESC
        vitalsData.value = Array.from(vitalsMap.values()).sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

        console.log("Sorted & Grouped Vitals Data:", vitalsData.value);

      updateChartData(); // always update the chart after vitals have been fetched
      } catch (error) {
      console.error('Error fetching vitals:', error);
      }
      }

function updateChartData() {
  const labels = vitalsData.value.map(item => new Date(item.timestamp).toLocaleString());

  chartData.value = {
    labels,
    datasets: [
      {
        label: "Systolic",
        borderColor: "red",
        backgroundColor: "rgba(255, 99, 132, 0.2)",
        borderWidth: 2,
        data: vitalsData.value.map(item => item.Systolic.value), // Extract only numeric values
        customData: vitalsData.value.map(item => item.Systolic.template) // show template name as a tooltip
      },
      {
        label: "Diastolic",
        borderColor: "blue",
        backgroundColor: "rgba(54, 162, 235, 0.2)",
        borderWidth: 2,
        data: vitalsData.value.map(item => item.Diastolic.value),
        customData: vitalsData.value.map(item => item.Diastolic.template)
      },
      {
        label: "Pulse Rate",
        borderColor: "green",
        backgroundColor: "rgba(75, 192, 192, 0.2)",
        borderWidth: 2,
        data: vitalsData.value.map(item => item["Pulse rate"].value),
        customData: vitalsData.value.map(item => item["Pulse rate"].template)
      }
    ]
  };
  console.log("Updated Chart Data:", chartData.value);
}

watch(selectedTemplate, () => {
  console.log("Watcher triggered. Template changed to:", selectedTemplate.value);
  fetchVitals(); // Fetch vitals based on the selected template
});

const vitalsData = ref([]); // Stores fetched vitals data
const chartData = ref({ labels: [], datasets: [] }); // Stores chart data

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'
import { Line } from 'vue-chartjs'


const chartOptions = {
  responsive: true, /* responsive design/layout */
  maintainAspectRatio: false,
  plugins: {
    legend: { labels: { color: "black" } },
    tooltip: { // tooltip for displaying the template ID on mouse-over
      callbacks: {
        label: function(tooltipItem) {
          const dataset = tooltipItem.dataset;
          const value = dataset.data[tooltipItem.dataIndex];
          const template = dataset.customData ? dataset.customData[tooltipItem.dataIndex] : "Unknown Template";

          return `Value: ${value} (Template: ${template})`;
        }
      }
    }
  },
  scales: {
    x: { ticks: { color: "black" } },
    y: { ticks: { color: "black" } }
  }
};


ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

onMounted(() => {
    loadCompositions();
    fetchVitals()
});

</script>

<template>

<div class="page-container">
    
    <!-- Centered Header -->
    <div class="header-container">
      <h1>openEHR Vitals Compositions</h1>
      <h3>Current EHR ID: {{ ehrId }}</h3>
    </div>

    <div class="vitals-left-container">

        <!-- Left Side: Display Section (Chart & Table) -->
        <div class="display-section">
            <h2>{{ selectedComposition ? 'Composition Details' : 'Query Compositions by Template' }}  </h2>
            <!-- Dropdown for selecting a template available in this EHR; optionValue="value" is essential for the value to be stored -->
            <Select v-model="selectedTemplate" :options="templates" optionLabel="name" optionValue="value" placeholder="Select a Template" class="w-full md:w-14rem" />

<!--         Chart with PrimeVue (not working so far)
             <div class="card">
                <Chart type="line" :data="chartData" :options="chartOptions" class="h-[30rem]" />
            </div> -->

<!--        Chart with chart.js      -->
      <div class="chart-container">
      <Line
          id="my-chart-id"
          :options="chartOptions"
          :data="chartData"
        />
      </div>

      <!-- Table for displaying fetched vitals -->
      <div class="table-container">
  <h3>Vitals Data Table</h3>
  <table class="vitals-table">
    <thead>
      <tr>
        <th>Timestamp</th>
        <th>Systolic</th>
        <th>Template</th>
        <th>Diastolic</th>
        <th>Template</th>
        <th>Pulse Rate</th>
        <th>Template</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="vital in vitalsData" :key="vital.timestamp">
        <td>{{ new Date(vital.timestamp).toLocaleString() }}</td>
        <td>{{ vital.Systolic.value !== null ? vital.Systolic.value : "-" }}</td>
        <td>{{ vital.Systolic.template ? vital.Systolic.template : "-" }}</td>
        <td>{{ vital.Diastolic.value !== null ? vital.Diastolic.value : "-" }}</td>
        <td>{{ vital.Diastolic.template ? vital.Diastolic.template : "-" }}</td>
        <td>{{ vital["Pulse rate"].value !== null ? vital["Pulse rate"].value : "-" }}</td>
        <td>{{ vital["Pulse rate"].template ? vital["Pulse rate"].template : "-" }}</td>
      </tr>
    </tbody>
  </table>
</div>


            <!-- Composition Text Display -->
            <div v-if="compositionText" class="composition-text">
                <h3>Composition Content</h3>
                <pre>{{ compositionText }}</pre> <!-- Displays the composition content as plain text -->
            </div>

        </div>

        <!-- Right Side: Compositions Section -->
        <div class="compositions-section">
            <h2>Compositions</h2>
            <div v-if="loading">Loading compositions...</div>
            <div v-else-if="error" class="error">{{ error }}</div>
            <div v-else class="grid">
                <div v-for="composition in filteredCompositions" :key="composition.uid" class="card" @click="showCompositionAsText(composition.uid)">
                    <p><strong>UID:</strong> {{ composition.uid }}</p>
                    <p><strong>TemplateId:</strong> {{ composition.template }}</p>
                    <p><strong>Timestamp:</strong> {{ new Date(composition.timestamp).toLocaleString() }}</p>
                </div>
            </div>
        </div>
    </div>
    <Toast position="bottom-left"/>
  </div>
</template>


<style scoped>

/* Center the entire page */
.page-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
}

/* Center the header */
.header-container {
    text-align: center;
    margin-bottom: 20px;
    width: 100%;
}

.vitals-left-container {
  display: flex;
    justify-content: center; /* Center horizontally */
    align-items: flex-start; /* Align to the top */
    gap: 40px;
    width: 100vw;
    padding: 20px;
    box-sizing: border-box;
}

/* Left Side (Chart Section) */
.display-section {
    justify-content: center;
    
    width: 50vw; /* Take half of the viewport width */
    max-width: 900px; /* Prevent it from being too wide */
}

.composition-text {
    margin-top: 20px;
    padding: 15px;
    border-radius: 8px;
    background-color: #f5f5f5;
    color: black;
    font-family: monospace;
    white-space: pre-wrap; /* Ensures text formatting is preserved */
    word-wrap: break-word;
    font-size: 0.8em;
}

/* Right Side (Compositions Section) */
.compositions-section {
    justify-content: flex-start;
    width: 30vw; /* Allow it to be flexible */
    max-width: 500px; /* Prevent it from stretching too much */
    /*background-color: rgb(247, 247, 247)*/
}

.display-section, .compositions-section {
  display: flex;
    flex-direction: column;
    align-items: center; /* Center the chart and table */
    justify-content: center;
}

/* Grid Layout for Compositions */
.grid {
    display: grid;
    gap: 15px;
}

/* Card Styling */
.card {
    color: black;
    border: 1px solid #ccc;
    padding: 15px;
    border-radius: 8px;
    max-width: 600px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    background-color: white;
    transition: box-shadow 0.3s ease, transform 0.3s ease, background-color 0.3s ease;
    cursor: pointer; /* Add cursor pointer to indicate clickable */
}

.card:hover {
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.card:active {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    transform: translateY(2px);
    background-color: #f0f0f0; /* Slight grey background while clicking */
}

/* Error Message Styling */
.error {
    color: red;
    font-weight: bold;
}

/* Responsive Fix */
@media (max-width: 768px) {
    .vitals-left-container {
        grid-template-columns: 1fr; /* Stack on smaller screens */
    }

    .display-section {
        border-right: none; /* Remove separator */
    }
}

/* define the backgroundcolor of the chart */
canvas {
  width: 100% !important; /* Ensure it takes up full width */
  height: 100% !important; /* Maintain proportional height */
  background-color: white !important;
}

.table-container {
    margin-top: 20px;
    overflow-x: auto; /* Ensure responsiveness */
} 

.chart-container, .table-container {
    width: 100%; /* Ensure they take full width */
    max-width: 800px; /* Prevent excessive stretching */
    margin: 0 auto; /* Center them */
}

.vitals-table {
    width: 100%;
    border-collapse: collapse;
}

.vitals-table th, .vitals-table td {
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}

.vitals-table th {
    background-color: #f4f4f4;
    font-weight: bold;
}

.vitals-table tr:nth-child(even) {
    background-color: #f9f9f9;
}




</style>
